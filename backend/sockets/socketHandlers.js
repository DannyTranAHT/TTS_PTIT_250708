const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Project = require('../models/Project');
const Notification = require('../models/Notification');
const { createNotification, emitNotificationCount } = require('../services/notificationService');

// ANALYTICS TRACKING
class SocketAnalytics {
  constructor() {
    this.metrics = {
      connections: 0,
      disconnections: 0,
      events: {},
      errors: 0,
      messages_sent: 0,
      active_users: new Set()
    };
  }

  trackConnection(userId) {
    this.metrics.connections++;
    this.metrics.active_users.add(userId);
  }

  trackDisconnection(userId) {
    this.metrics.disconnections++;
    this.metrics.active_users.delete(userId);
  }

  trackEvent(eventName) {
    this.metrics.events[eventName] = (this.metrics.events[eventName] || 0) + 1;
  }

  trackError() {
    this.metrics.errors++;
  }

  getMetrics() {
    return {
      ...this.metrics,
      active_users: this.metrics.active_users.size,
      events_copy: { ...this.metrics.events },
      timestamp: new Date()
    };
  }
}

const analytics = new SocketAnalytics();

// CONNECTION TRACKING
const activeConnections = new Map();

// ERROR HANDLER
const handleSocketError = (socket, error, context = '') => {
  console.error(`❌ Socket Error [${context}]:`, {
    error: error.message,
    user_id: socket.user?._id,
    socket_id: socket.id,
    timestamp: new Date()
  });

  analytics.trackError();

  socket.emit('error', {
    type: 'socket_error',
    message: 'An error occurred. Please try again.',
    context,
    timestamp: new Date()
  });
};

// WRAPPER FOR ERROR HANDLING
const wrapHandler = (socket, handler) => {
  return async (data) => {
    try {
      await handler(data);
    } catch (error) {
      handleSocketError(socket, error, 'handler_execution');
    }
  };
};

const setupSocketHandlers = (io) => {
  //  AUTHENTICATION MIDDLEWARE
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return next(new Error('Authentication error: User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication error: Invalid token'));
    }
  });

  //  CONNECTION HANDLER
  io.on('connection', async (socket) => {
    console.log(`✅ User ${socket.user.username} connected (${socket.id})`);
    
    // Track connection
    analytics.trackConnection(socket.user._id);
    activeConnections.set(socket.id, {
      user_id: socket.user._id,
      username: socket.user.username,
      connected_at: new Date(),
      last_activity: new Date()
    });

    // Auto-join user room
    socket.join(`user_${socket.user._id}`);

    // Track activity on any event
    socket.use((packet, next) => {
      const connection = activeConnections.get(socket.id);
      if (connection) {
        connection.last_activity = new Date();
      }
      analytics.trackEvent(packet[0]);
      next();
    });

    // Send initial notification count
    try {
      const { getUnreadCount } = require('../services/notificationService');
      const unreadCount = await getUnreadCount(socket.user._id);
      socket.emit('notifications:count', { count: unreadCount });
    } catch (error) {
      console.error('Error sending initial notification count:', error);
    }

    // ===== PROJECT EVENTS =====
    socket.on('project:join', wrapHandler(socket, async (projectId) => {
      socket.join(`project_${projectId}`);
      socket.to(`project_${projectId}`).emit('project:user_joined', {
        user: {
          _id: socket.user._id,
          username: socket.user.username,
          full_name: socket.user.full_name
        },
        message: `${socket.user.full_name} joined the project`,
        timestamp: new Date()
      });
    }));

    socket.on('project:leave', wrapHandler(socket, async (projectId) => {
      socket.leave(`project_${projectId}`);
      socket.to(`project_${projectId}`).emit('project:user_left', {
        user: {
          _id: socket.user._id,
          username: socket.user.username,
          full_name: socket.user.full_name
        },
        message: `${socket.user.full_name} left the project`,
        timestamp: new Date()
      });
    }));

    // ===== TASK EVENTS =====
    socket.on('task:status_update', wrapHandler(socket, async (data) => {
      const { task_id, project_id, old_status, new_status } = data;
      
      socket.to(`project_${project_id}`).emit('task:status_updated', {
        task_id,
        old_status,
        new_status,
        updated_by: socket.user.full_name,
        updated_by_id: socket.user._id,
        timestamp: new Date()
      });
    }));

    // ===== COMMENT EVENTS =====
    socket.on('comment:typing', wrapHandler(socket, async (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('comment:user_typing', {
        entity_type,
        entity_id,
        user: {
          _id: socket.user._id,
          full_name: socket.user.full_name
        },
        timestamp: new Date()
      });
    }));

    socket.on('comment:stop_typing', wrapHandler(socket, async (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('comment:user_stop_typing', {
        entity_type,
        entity_id,
        user_id: socket.user._id
      });
    }));

    // ===== PRIVATE MESSAGING =====
    socket.on('message:private', wrapHandler(socket, async (data) => {
      const { recipient_id, message } = data;
      
      // Validate recipient_id
      const mongoose = require('mongoose');
      if (!mongoose.Types.ObjectId.isValid(recipient_id)) {
        socket.emit('error', { message: 'Invalid recipient ID' });
        return;
      }
      
      // Send message to recipient
      io.to(`user_${recipient_id}`).emit('message:received', {
        from: {
          _id: socket.user._id,
          username: socket.user.username,
          full_name: socket.user.full_name
        },
        message,
        timestamp: new Date()
      });

      // Create notification
      try {
        await createNotification({
          user_id: recipient_id,
          type: 'comment_added',
          title: 'New Message',
          message: `${socket.user.full_name} sent you a message`,
          related_entity: {
            entity_type: 'Comment',
            entity_id: socket.user._id
          }
        }, io);
      } catch (notificationError) {
        console.error('Error creating notification:', notificationError);
      }
    }));

    // ===== NOTIFICATION SOCKET HANDLERS ===== 
    socket.on('notifications:mark_read', wrapHandler(socket, async (data) => {
      const { notification_id } = data;
      
      const notification = await Notification.findOneAndUpdate(
        { _id: notification_id, user_id: socket.user._id },
        { is_read: true },
        { new: true }
      );
      
      if (notification) {
        await emitNotificationCount(socket.user._id, io);
        socket.emit('notification:marked_read', { notification_id });
      } else {
        socket.emit('error', { 
          type: 'notification_error',
          message: 'Notification not found or already read' 
        });
      }
    }));

    socket.on('notifications:mark_all_read', wrapHandler(socket, async () => {
      await Notification.updateMany(
        { user_id: socket.user._id, is_read: false },
        { is_read: true }
      );
      
      socket.emit('notifications:count', { count: 0 });
      socket.emit('notifications:all_marked_read');
    }));

    socket.on('notifications:delete', wrapHandler(socket, async (data) => {
      const { notification_id } = data;
      
      const notification = await Notification.findOneAndDelete({
        _id: notification_id,
        user_id: socket.user._id
      });
      
      if (notification) {
        if (!notification.is_read) {
          await emitNotificationCount(socket.user._id, io);
        }
        socket.emit('notification:deleted', { notification_id });
      }
    }));

    // ===== USER PRESENCE SYSTEM ===== 🆕
    socket.on('user:set_status', wrapHandler(socket, async (data) => {
      const { status } = data; // online, away, busy, offline
      
      // Update user status in database (optional)
      await User.findByIdAndUpdate(socket.user._id, { 
        status, 
        last_active: new Date() 
      });
      
      // Broadcast to all project rooms
      socket.rooms.forEach(room => {
        if (room.startsWith('project_')) {
          socket.to(room).emit('user:status_changed', {
            user_id: socket.user._id,
            username: socket.user.username,
            full_name: socket.user.full_name,
            status,
            timestamp: new Date()
          });
        }
      });
    }));

    // ===== ENHANCED TYPING INDICATORS ===== 
    socket.on('user:typing_start', wrapHandler(socket, async (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('user:typing', {
        entity_type,
        entity_id,
        user: {
          _id: socket.user._id,
          full_name: socket.user.full_name
        },
        timestamp: new Date()
      });
    }));

    socket.on('user:typing_stop', wrapHandler(socket, async (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('user:stop_typing', {
        entity_type,
        entity_id,
        user_id: socket.user._id
      });
    }));

    // ===== SYSTEM EVENTS ===== 🆕
    socket.on('system:ping', wrapHandler(socket, async () => {
      socket.emit('system:pong', { 
        server_time: new Date(),
        user_id: socket.user._id,
        socket_id: socket.id
      });
    }));

    socket.on('system:get_metrics', wrapHandler(socket, async () => {
      // Only allow admins to see metrics
      if (socket.user.role === 'Admin') {
        socket.emit('system:metrics', analytics.getMetrics());
      }
    }));

    // ===== DISCONNECT HANDLER =====
    socket.on('disconnect', (reason) => {
      console.log(`❌ User ${socket.user.username} disconnected: ${reason}`);
      
      // Track disconnection
      analytics.trackDisconnection(socket.user._id);
      activeConnections.delete(socket.id);
      
      // Notify others in project rooms that user went offline
      socket.rooms.forEach(room => {
        if (room.startsWith('project_')) {
          socket.to(room).emit('user:offline', {
            user_id: socket.user._id,
            username: socket.user.username,
            timestamp: new Date()
          });
        }
      });
    });
  });

  // Helper functions
  const emitToProjectMembers = async (projectId, event, data, excludeUserId = null) => {
    try {
      const project = await Project.findById(projectId).populate('members', '_id');
      if (!project) return;

      project.members.forEach(member => {
        if (!excludeUserId || member._id.toString() !== excludeUserId.toString()) {
          io.to(`user_${member._id}`).emit(event, data);
        }
      });
    } catch (error) {
      console.error('Error emitting to project members:', error);
    }
  };

  const emitToUser = (userId, event, data) => {
    io.to(`user_${userId}`).emit(event, data);
  };

  const emitToProject = (projectId, event, data) => {
    io.to(`project_${projectId}`).emit(event, data);
  };

  //EXPORT ANALYTICS FOR MONITORING
  const getAnalytics = () => analytics.getMetrics();
  const getActiveConnections = () => Array.from(activeConnections.values());

  return {
    emitToProjectMembers,
    emitToUser,
    emitToProject,
    getAnalytics,
    getActiveConnections
  };
};

module.exports = setupSocketHandlers;