const Notification = require('../models/Notification');

// ENHANCED NOTIFICATION CREATION WITH ROBUST ERROR HANDLING
const createNotification = async (notificationData, io = null) => {
  try {
    // 1. Create notification in database first (critical operation)
    const notification = await Notification.create(notificationData);
    console.log('✅ Notification created in DB:', notification._id);

    // 2. Handle socket operations separately (non-critical)
    if (io) {
      await handleSocketNotifications(notification, notificationData, io);
    } else {
      console.warn('⚠️ Socket.IO not provided - notification created but not pushed realtime');
    }
    
    return notification;
  } catch (error) {
    console.error('❌ Error creating notification:', error);
    throw error;
  }
};

// SEPARATE SOCKET OPERATIONS FOR BETTER ERROR ISOLATION
const handleSocketNotifications = async (notification, notificationData, io) => {
  try {
    // Check if socket server is healthy
    if (!io || typeof io.to !== 'function') {
      console.warn('⚠️ Socket.IO server not healthy');
      return;
    }

    // Emit new notification with timeout protection
    const emitWithTimeout = (room, event, data, timeout = 5000) => {
      return new Promise((resolve, reject) => {
        const timer = setTimeout(() => {
          reject(new Error(`Socket emit timeout for ${event}`));
        }, timeout);

        try {
          io.to(room).emit(event, data);
          clearTimeout(timer);
          resolve();
        } catch (error) {
          clearTimeout(timer);
          reject(error);
        }
      });
    };

    // 1. Emit new notification
    try {
      await emitWithTimeout(`user_${notificationData.user_id}`, 'notification:new', {
        id: notification._id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        created_at: notification.created_at,
        related_entity: notification.related_entity,
        is_read: notification.is_read
      });
      console.log('✅ New notification emitted to user:', notificationData.user_id);
    } catch (emitError) {
      console.error('❌ Failed to emit new notification:', emitError);
    }

    // 2. Update badge count
    try {
      const newCount = await getUnreadCount(notificationData.user_id);
      await emitWithTimeout(`user_${notificationData.user_id}`, 'notifications:count', { 
        count: newCount 
      });
      console.log('✅ Notification count updated for user:', notificationData.user_id);
    } catch (countError) {
      console.error('❌ Failed to emit notification count:', countError);
    }

    // 3. Optional system analytics (non-critical)
    try {
      io.emit('system:notification_sent', {
        user_id: notificationData.user_id,
        type: notificationData.type,
        timestamp: new Date()
      });
    } catch (analyticsError) {
      console.error('⚠️ Analytics emit failed (non-critical):', analyticsError);
    }

  } catch (socketError) {
    console.error('❌ Socket notification handling failed:', socketError);
    // Don't throw - notification was already saved to DB
  }
};

// IMPROVED EMIT NOTIFICATION COUNT WITH FALLBACK
const emitNotificationCount = async (userId, io) => {
  try {
    if (!io) {
      console.warn('⚠️ Socket.IO not available for notification count');
      return;
    }

    const count = await getUnreadCount(userId);
    
    // Add connection check
    const userRoom = `user_${userId}`;
    const socketsInRoom = await io.in(userRoom).allSockets();
    
    if (socketsInRoom.size === 0) {
      console.log(`⚠️ No active sockets for user ${userId}`);
      return;
    }

    io.to(userRoom).emit('notifications:count', { count });
    console.log(`✅ Notification count (${count}) emitted to user ${userId}`);
    
  } catch (error) {
    console.error('❌ Failed to emit notification count:', error);
    // Don't throw - this is a non-critical operation
  }
};

// IMPROVED GET UNREAD COUNT WITH ERROR HANDLING
const getUnreadCount = async (userId) => {
  try {
    const count = await Notification.countDocuments({
      user_id: userId,
      is_read: false
    });
    return count;
  } catch (error) {
    console.error('❌ Error getting unread count:', error);
    return 0; // Return 0 as fallback
  }
};

// HEALTH CHECK FOR SOCKET OPERATIONS
const isSocketHealthy = (io) => {
  return io && 
         typeof io.to === 'function' && 
         typeof io.emit === 'function' &&
         io.engine && 
         io.engine.clientsCount !== undefined;
};

module.exports = {
  createNotification,
  emitNotificationCount,
  getUnreadCount,
  handleSocketNotifications,
  isSocketHealthy
};