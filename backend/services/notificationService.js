const Notification = require('../models/Notification');

//ENHANCED NOTIFICATION CREATION WITH REALTIME SOCKET
const createNotification = async (notificationData, io = null) => {
  try {
    const notification = await Notification.create(notificationData);
    
    //  REALTIME NOTIFICATION PUSH
    if (io) {
      // Emit new notification
      io.to(`user_${notificationData.user_id}`).emit('notification:new', {
        id: notification._id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        created_at: notification.created_at,
        related_entity: notification.related_entity,
        is_read: notification.is_read
      });
      
      //  UPDATE BADGE COUNT REALTIME
      const newCount = await getUnreadCount(notificationData.user_id);
      io.to(`user_${notificationData.user_id}`).emit('notifications:count', { 
        count: newCount 
      });
      
      // EMIT SYSTEM ANALYTICS (optional)
      io.emit('system:notification_sent', {
        user_id: notificationData.user_id,
        type: notificationData.type,
        timestamp: new Date()
      });
    }
    
    return notification;
  } catch (error) {
    console.error('❌ Error creating notification:', error);
    throw error;
  }
};

// BULK NOTIFICATIONS WITH SOCKET OPTIMIZATION
const createBulkNotifications = async (notifications, io = null) => {
  try {
    const createdNotifications = await Notification.insertMany(notifications);
    
    if (io) {
      // Group notifications by user_id for efficient emission
      const userGroups = createdNotifications.reduce((acc, notif) => {
        const userId = notif.user_id.toString();
        acc[userId] = acc[userId] || [];
        acc[userId].push(notif);
        return acc;
      }, {});
      
      // Emit to each user efficiently
      for (const [userId, userNotifs] of Object.entries(userGroups)) {
        // Emit each notification
        userNotifs.forEach(notif => {
          io.to(`user_${userId}`).emit('notification:new', {
            id: notif._id,
            title: notif.title,
            message: notif.message,
            type: notif.type,
            created_at: notif.created_at,
            related_entity: notif.related_entity
          });
        });
        
        // Update count once per user
        await emitNotificationCount(userId, io);
      }
    }
    
    return createdNotifications;
  } catch (error) {
    console.error('❌ Error creating bulk notifications:', error);
    throw error;
  }
};

// HELPER FUNCTION FOR COUNT UPDATES
const emitNotificationCount = async (userId, io) => {
  try {
    const count = await getUnreadCount(userId);
    io.to(`user_${userId}`).emit('notifications:count', { count });
    return count;
  } catch (error) {
    console.error('❌ Error emitting notification count:', error);
    return 0;
  }
};

const getUnreadCount = async (userId) => {
  try {
    const count = await Notification.countDocuments({
      user_id: userId,
      is_read: false
    });
    return count;
  } catch (error) {
    console.error('Error getting unread count:', error);
    return 0;
  }
};

const markNotificationsAsRead = async (userId, notificationIds = null) => {
  try {
    const query = { user_id: userId, is_read: false };
    
    if (notificationIds) {
      query._id = { $in: notificationIds };
    }
    
    const result = await Notification.updateMany(query, { is_read: true });
    return result;
  } catch (error) {
    console.error('Error marking notifications as read:', error);
    throw error;
  }
};

// BATCH MARK AS READ WITH SOCKET
const markMultipleAsRead = async (notificationIds, userId, io = null) => {
  try {
    const result = await Notification.updateMany(
      { 
        _id: { $in: notificationIds },
        user_id: userId,
        is_read: false 
      },
      { is_read: true }
    );

    if (io && result.modifiedCount > 0) {
      await emitNotificationCount(userId, io);
      io.to(`user_${userId}`).emit('notifications:batch_marked_read', {
        notification_ids: notificationIds,
        count: result.modifiedCount
      });
    }

    return result;
  } catch (error) {
    console.error('Error marking multiple notifications as read:', error);
    throw error;
  }
};

const deleteOldNotifications = async (daysOld = 30) => {
  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysOld);
    
    const result = await Notification.deleteMany({
      created_at: { $lt: cutoffDate },
      is_read: true
    });
    
    console.log(`🗑️ Deleted ${result.deletedCount} old notifications`);
    return result;
  } catch (error) {
    console.error('Error deleting old notifications:', error);
    throw error;
  }
};

module.exports = {
  createNotification,
  createBulkNotifications,
  getUnreadCount,
  markNotificationsAsRead,
  markMultipleAsRead,
  deleteOldNotifications,
  emitNotificationCount 
};