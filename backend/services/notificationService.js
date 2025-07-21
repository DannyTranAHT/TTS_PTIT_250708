const Notification = require('../models/Notification');

const createNotification = async (notificationData) => {
  try {
    const notification = await Notification.create(notificationData);
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    throw error;
  }
};

const createBulkNotifications = async (notifications) => {
  try {
    const createdNotifications = await Notification.insertMany(notifications);
    return createdNotifications;
  } catch (error) {
    console.error('Error creating bulk notifications:', error);
    throw error;
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

const deleteOldNotifications = async (daysOld = 30) => {
  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysOld);
    
    const result = await Notification.deleteMany({
      created_at: { $lt: cutoffDate },
      is_read: true
    });
    
    console.log(`Deleted ${result.deletedCount} old notifications`);
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
  deleteOldNotifications
};