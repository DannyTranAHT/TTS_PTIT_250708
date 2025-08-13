const Notification = require('../models/Notification');
const { emitNotificationCount } = require('../services/notificationService');

const getNotifications = async (req, res) => {
  try {
    const { page = 1, limit = 20, is_read } = req.query;
    
    const query = { user_id: req.user._id };
    
    // Filter by read status if specified
    if (is_read !== undefined) {
      query.is_read = is_read === 'true';
    }

    const notifications = await Notification.find(query)
      .sort({ created_at: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Notification.countDocuments(query);
    const unreadCount = await Notification.countDocuments({
      user_id: req.user._id,
      is_read: false
    });

    res.json({
      notifications,
      totalPages: Math.ceil(total / limit),
      currentPage: parseInt(page),
      total,
      unreadCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//  ENHANCED WITH SOCKET EVENTS
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, user_id: req.user._id },
      { is_read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    // REALTIME SOCKET UPDATE
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${req.user._id}`).emit('notification:marked_read', {
        notification_id: id
      });
      
      // Update count
      await emitNotificationCount(req.user._id, io);
    }

    res.json({ 
      message: 'Notification marked as read',
      notification 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//  ENHANCED WITH SOCKET EVENTS
const markAllAsRead = async (req, res) => {
  try {
    const result = await Notification.updateMany(
      { user_id: req.user._id, is_read: false },
      { is_read: true }
    );

    // 🚀 REALTIME SOCKET UPDATE
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${req.user._id}`).emit('notifications:all_marked_read');
      io.to(`user_${req.user._id}`).emit('notifications:count', { count: 0 });
    }

    res.json({ 
      message: 'All notifications marked as read',
      modifiedCount: result.modifiedCount 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//  ENHANCED WITH SOCKET EVENTS
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndDelete({
      _id: id,
      user_id: req.user._id
    });

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    //  REALTIME SOCKET UPDATE
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${req.user._id}`).emit('notification:deleted', {
        notification_id: id
      });
      
      // Update count if it was unread
      if (!notification.is_read) {
        await emitNotificationCount(req.user._id, io);
      }
    }

    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      user_id: req.user._id,
      is_read: false
    });

    res.json({ count });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// BATCH OPERATIONS
const markMultipleAsRead = async (req, res) => {
  try {
    const { notification_ids } = req.body;
    
    if (!Array.isArray(notification_ids)) {
      return res.status(400).json({ message: 'notification_ids must be an array' });
    }

    const result = await Notification.updateMany(
      { 
        _id: { $in: notification_ids },
        user_id: req.user._id,
        is_read: false 
      },
      { is_read: true }
    );

    // REALTIME SOCKET UPDATE
    const io = req.app.get('io');
    if (io && result.modifiedCount > 0) {
      await emitNotificationCount(req.user._id, io);
      io.to(`user_${req.user._id}`).emit('notifications:batch_marked_read', {
        notification_ids,
        count: result.modifiedCount
      });
    }

    res.json({ 
      message: `${result.modifiedCount} notifications marked as read`,
      modifiedCount: result.modifiedCount 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getUnreadCount,
  markMultipleAsRead
};