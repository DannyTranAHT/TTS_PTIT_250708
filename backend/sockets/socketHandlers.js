const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Project = require('../models/Project');
const Notification = require('../models/Notification');
const { createNotification, emitNotificationCount } = require('../services/notificationService');

// SIMPLE HEALTH MONITOR (BUILT-IN)
class SimpleSocketMonitor {
  constructor() {
    this.connections = 0;
    this.errors = 0;
    this.startTime = new Date();
  }

  trackConnection() {
    this.connections++;
  }

  trackError(error, context = {}) {
    this.errors++;
    console.error(`🚨 Socket Error [${context.source || 'unknown'}]:`, {
      error: error.message,
      context,
      timestamp: new Date()
    });
  }

  getMetrics() {
    return {
      connections: this.connections,
      errors: this.errors,
      uptime: Date.now() - this.startTime.getTime(),
      error_rate: this.connections > 0 ? (this.errors / this.connections * 100).toFixed(2) : 0
    };
  }
}

const simpleMonitor = new SimpleSocketMonitor();

// ANALYTICS TRACKING
class SocketAnalytics {
  constructor() {
    this.metrics = {
      connections: 0,
      disconnections: 0,
      events: {},
      errors: 0,
      messages_sent: 0,
      active_users: new Set(),
      retry_attempts: 0,
      failed_operations: 0
    };
  }

  trackConnection(userId) {
    this.metrics.connections++;
    this.metrics.active_users.add(userId);
    simpleMonitor.trackConnection();
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

  trackRetry() {
    this.metrics.retry_attempts++;
  }

  trackFailedOperation() {
    this.metrics.failed_operations++;
  }

  getMetrics() {
    return {
      ...this.metrics,
      active_users: this.metrics.active_users.size,
      events_copy: { ...this.metrics.events },
      timestamp: new Date(),
      error_rate: this.metrics.connections > 0 ? (this.metrics.errors / this.metrics.connections * 100).toFixed(2) : 0
    };
  }

  reset() {
    this.metrics = {
      connections: 0,
      disconnections: 0,
      events: {},
      errors: 0,
      messages_sent: 0,
      active_users: new Set(),
      retry_attempts: 0,
      failed_operations: 0
    };
  }
}

const analytics = new SocketAnalytics();

// CONNECTION TRACKING
const activeConnections = new Map();

// ENHANCED ERROR HANDLER WITH DETAILED LOGGING
const handleSocketError = (socket, error, context = '') => {
  const errorDetails = {
    error: error.message,
    stack: error.stack,
    user_id: socket.user?._id,
    username: socket.user?.username,
    socket_id: socket.id,
    context,
    timestamp: new Date(),
    user_agent: socket.handshake.headers['user-agent'],
    ip: socket.handshake.address
  };

  console.error(`❌ Socket Error [${context}]:`, errorDetails);
  analytics.trackError();
  simpleMonitor.trackError(error, { source: context });

  // Send user-friendly error message
  try {
    socket.emit('error', {
      type: 'socket_error',
      message: 'Connection issue occurred. Please try again.',
      context,
      timestamp: new Date(),
      error_id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    });
  } catch (emitError) {
    console.error('❌ Failed to emit error message:', emitError);
  }
};

// ENHANCED WRAPPER WITH RETRY MECHANISM
const wrapHandler = (socket, handler, options = {}) => {
  const { 
    maxRetries = 1, 
    retryDelay = 1000, 
    criticalOperation = false,
    timeoutMs = 10000 
  } = options;
  
  return async (data) => {
    let attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        // Add timeout for critical operations
        if (criticalOperation) {
          const timeoutPromise = new Promise((_, reject) => {
            setTimeout(() => reject(new Error('Operation timeout')), timeoutMs);
          });
          
          await Promise.race([handler(data), timeoutPromise]);
        } else {
          await handler(data);
        }
        
        return; // Success, exit retry loop
      } catch (error) {
        attempts++;
        analytics.trackRetry();
        
        if (attempts > maxRetries) {
          analytics.trackFailedOperation();
          handleSocketError(socket, error, `handler_execution_final_attempt_${attempts}`);
          return;
        }
        
        console.warn(`⚠️ Socket handler failed (attempt ${attempts}/${maxRetries + 1}):`, {
          error: error.message,
          user: socket.user?.username,
          handler: handler.name || 'anonymous'
        });
        
        // Wait before retry for non-critical operations
        if (retryDelay > 0 && attempts <= maxRetries && !criticalOperation) {
          await new Promise(resolve => setTimeout(resolve, retryDelay));
        }
      }
    }
  };
};

// HELPER FUNCTIONS
const isValidObjectId = (id) => {
  const mongoose = require('mongoose');
  return mongoose.Types.ObjectId.isValid(id);
};

const emitWithErrorHandling = (socket, event, data, room = null) => {
  try {
    if (room) {
      socket.to(room).emit(event, data);
    } else {
      socket.emit(event, data);
    }
    analytics.metrics.messages_sent++;
    return true;
  } catch (error) {
    console.error(`❌ Failed to emit ${event}:`, error);
    simpleMonitor.trackError(error, { source: 'emit_failed', event });
    return false;
  }
};

const setupSocketHandlers = (io) => {
  console.log('🚀 Setting up socket handlers with built-in monitoring...');

  // AUTHENTICATION MIDDLEWARE
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
      next(new Error(`Authentication error: ${err.message}`));
    }
  });

  // CONNECTION HANDLER
  io.on('connection', async (socket) => {
    console.log(`✅ User ${socket.user.username} connected (${socket.id})`);
    
    try {
      // Track connection
      analytics.trackConnection(socket.user._id);

      activeConnections.set(socket.id, {
        user_id: socket.user._id,
        username: socket.user.username,
        connected_at: new Date(),
        last_activity: new Date(),
        health_status: 'connected',
        rooms: new Set()
      });

      // Auto-join user room with error handling
      try {
        socket.join(`user_${socket.user._id}`);
        console.log(`✅ User ${socket.user.username} joined room: user_${socket.user._id}`);
      } catch (joinError) {
        console.error('❌ Failed to join user room:', joinError);
        handleSocketError(socket, joinError, 'user_room_join');
      }

      // Track activity on any event
      socket.use((packet, next) => {
        const connection = activeConnections.get(socket.id);
        if (connection) {
          connection.last_activity = new Date();
        }
        analytics.trackEvent(packet[0]);
        next();
      });

      // Send initial notification count with error handling
      try {
        const { getUnreadCount } = require('../services/notificationService');
        const unreadCount = await getUnreadCount(socket.user._id);
        emitWithErrorHandling(socket, 'notifications:count', { count: unreadCount });
        console.log(`✅ Initial notification count sent: ${unreadCount}`);
      } catch (notificationError) {
        console.error('❌ Error sending initial notification count:', notificationError);
        // Send 0 as fallback
        emitWithErrorHandling(socket, 'notifications:count', { count: 0 });
      }

      // Health check ping every 30 seconds
      const healthCheckInterval = setInterval(() => {
        try {
          emitWithErrorHandling(socket, 'system:ping', { timestamp: new Date() });
          
          // Update connection health status
          const connection = activeConnections.get(socket.id);
          if (connection) {
            connection.health_status = 'healthy';
            connection.last_ping = new Date();
          }
        } catch (pingError) {
          console.error('❌ Health check ping failed:', pingError);
          const connection = activeConnections.get(socket.id);
          if (connection) {
            connection.health_status = 'unhealthy';
          }
        }
      }, 30000);

      // Store interval for cleanup
      socket.healthCheckInterval = healthCheckInterval;

      // ===== PROJECT EVENTS =====
      socket.on('project:join', wrapHandler(socket, async (projectId) => {
        // Validate project ID
        if (!isValidObjectId(projectId)) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'validation_error',
            message: 'Invalid project ID format' 
          });
          return;
        }

        // Check if user has access to project
        const project = await Project.findById(projectId);
        if (!project) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'not_found',
            message: 'Project not found' 
          });
          return;
        }

        const hasAccess = project.owner_id.toString() === socket.user._id.toString() ||
                         project.members.some(member => member.toString() === socket.user._id.toString());

        if (!hasAccess) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'permission_denied',
            message: 'You do not have access to this project' 
          });
          return;
        }

        // Join project room
        socket.join(`project_${projectId}`);
        
        // Track room membership
        const connection = activeConnections.get(socket.id);
        if (connection) {
          connection.rooms.add(`project_${projectId}`);
        }

        // Notify others with error handling
        emitWithErrorHandling(socket, 'project:user_joined', {
          user: {
            _id: socket.user._id,
            username: socket.user.username,
            full_name: socket.user.full_name
          },
          message: `${socket.user.full_name} joined the project`,
          timestamp: new Date()
        }, `project_${projectId}`);

        console.log(`✅ User ${socket.user.username} joined project ${projectId}`);
      }, { maxRetries: 2, retryDelay: 1000, criticalOperation: true }));

      socket.on('project:leave', wrapHandler(socket, async (projectId) => {
        if (!isValidObjectId(projectId)) {
          return;
        }

        socket.leave(`project_${projectId}`);
        
        // Update room tracking
        const connection = activeConnections.get(socket.id);
        if (connection) {
          connection.rooms.delete(`project_${projectId}`);
        }

        emitWithErrorHandling(socket, 'project:user_left', {
          user: {
            _id: socket.user._id,
            username: socket.user.username,
            full_name: socket.user.full_name
          },
          message: `${socket.user.full_name} left the project`,
          timestamp: new Date()
        }, `project_${projectId}`);

        console.log(`✅ User ${socket.user.username} left project ${projectId}`);
      }, { maxRetries: 1 }));

      // ===== TASK EVENTS =====
      socket.on('task:status_update', wrapHandler(socket, async (data) => {
        const { task_id, project_id, old_status, new_status } = data;
        
        if (!isValidObjectId(task_id) || !isValidObjectId(project_id)) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'validation_error',
            message: 'Invalid task or project ID' 
          });
          return;
        }

        emitWithErrorHandling(socket, 'task:status_updated', {
          task_id,
          old_status,
          new_status,
          updated_by: socket.user.full_name,
          updated_by_id: socket.user._id,
          timestamp: new Date()
        }, `project_${project_id}`);
      }, { maxRetries: 2, retryDelay: 500 }));

      // ===== COMMENT EVENTS =====
      socket.on('comment:typing', wrapHandler(socket, async (data) => {
        const { entity_type, entity_id } = data;
        
        if (!entity_type || !entity_id) {
          return;
        }

        socket.broadcast.emit('comment:user_typing', {
          entity_type,
          entity_id,
          user: {
            _id: socket.user._id,
            full_name: socket.user.full_name
          },
          timestamp: new Date()
        });
      }, { maxRetries: 0 })); // No retry for typing indicators

      socket.on('comment:stop_typing', wrapHandler(socket, async (data) => {
        const { entity_type, entity_id } = data;
        
        if (!entity_type || !entity_id) {
          return;
        }

        socket.broadcast.emit('comment:user_stop_typing', {
          entity_type,
          entity_id,
          user_id: socket.user._id
        });
      }, { maxRetries: 0 }));

      // ===== PRIVATE MESSAGING =====
      socket.on('message:private', wrapHandler(socket, async (data) => {
        const { recipient_id, message } = data;
        
        // Validate recipient_id
        if (!isValidObjectId(recipient_id)) {
          emitWithErrorHandling(socket, 'error', { message: 'Invalid recipient ID' });
          return;
        }
        
        // Send message to recipient
        emitWithErrorHandling(socket, 'message:received', {
          from: {
            _id: socket.user._id,
            username: socket.user.username,
            full_name: socket.user.full_name
          },
          message,
          timestamp: new Date()
        }, `user_${recipient_id}`);

        // Create notification with error handling
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
          console.error('❌ Error creating message notification:', notificationError);
        }
      }, { maxRetries: 2, retryDelay: 1000, criticalOperation: true }));

      // ===== NOTIFICATION SOCKET HANDLERS ===== 
      socket.on('notifications:mark_read', wrapHandler(socket, async (data) => {
        const { notification_id } = data;
        
        if (!isValidObjectId(notification_id)) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'validation_error',
            message: 'Invalid notification ID' 
          });
          return;
        }
        
        const notification = await Notification.findOneAndUpdate(
          { _id: notification_id, user_id: socket.user._id },
          { is_read: true },
          { new: true }
        );
        
        if (notification) {
          await emitNotificationCount(socket.user._id, io);
          emitWithErrorHandling(socket, 'notification:marked_read', { notification_id });
        } else {
          emitWithErrorHandling(socket, 'error', { 
            type: 'notification_error',
            message: 'Notification not found or already read' 
          });
        }
      }, { maxRetries: 2, retryDelay: 1000 }));

      socket.on('notifications:mark_all_read', wrapHandler(socket, async () => {
        await Notification.updateMany(
          { user_id: socket.user._id, is_read: false },
          { is_read: true }
        );
        
        emitWithErrorHandling(socket, 'notifications:count', { count: 0 });
        emitWithErrorHandling(socket, 'notifications:all_marked_read');
      }, { maxRetries: 2, retryDelay: 1000 }));

      socket.on('notifications:delete', wrapHandler(socket, async (data) => {
        const { notification_id } = data;
        
        if (!isValidObjectId(notification_id)) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'validation_error',
            message: 'Invalid notification ID' 
          });
          return;
        }
        
        const notification = await Notification.findOneAndDelete({
          _id: notification_id,
          user_id: socket.user._id
        });
        
        if (notification) {
          if (!notification.is_read) {
            await emitNotificationCount(socket.user._id, io);
          }
          emitWithErrorHandling(socket, 'notification:deleted', { notification_id });
        }
      }, { maxRetries: 2, retryDelay: 1000 }));

      // ===== USER PRESENCE SYSTEM =====
      socket.on('user:set_status', wrapHandler(socket, async (data) => {
        const { status } = data; // online, away, busy, offline
        
        if (!['online', 'away', 'busy', 'offline'].includes(status)) {
          emitWithErrorHandling(socket, 'error', { 
            type: 'validation_error',
            message: 'Invalid status value' 
          });
          return;
        }
        
        // Update user status in database (optional)
        await User.findByIdAndUpdate(socket.user._id, { 
          status, 
          last_active: new Date() 
        });
        
        // Broadcast to all project rooms
        socket.rooms.forEach(room => {
          if (room.startsWith('project_')) {
            emitWithErrorHandling(socket, 'user:status_changed', {
              user_id: socket.user._id,
              username: socket.user.username,
              full_name: socket.user.full_name,
              status,
              timestamp: new Date()
            }, room);
          }
        });
      }, { maxRetries: 1 }));

      // ===== ENHANCED TYPING INDICATORS ===== 
      socket.on('user:typing_start', wrapHandler(socket, async (data) => {
        const { entity_type, entity_id } = data;
        
        if (!entity_type || !entity_id) {
          return;
        }

        socket.broadcast.emit('user:typing', {
          entity_type,
          entity_id,
          user: {
            _id: socket.user._id,
            full_name: socket.user.full_name
          },
          timestamp: new Date()
        });
      }, { maxRetries: 0 }));

      socket.on('user:typing_stop', wrapHandler(socket, async (data) => {
        const { entity_type, entity_id } = data;
        
        if (!entity_type || !entity_id) {
          return;
        }

        socket.broadcast.emit('user:stop_typing', {
          entity_type,
          entity_id,
          user_id: socket.user._id
        });
      }, { maxRetries: 0 }));

      // ===== SYSTEM EVENTS =====
      socket.on('system:ping', wrapHandler(socket, async () => {
        emitWithErrorHandling(socket, 'system:pong', { 
          server_time: new Date(),
          user_id: socket.user._id,
          socket_id: socket.id
        });
      }, { maxRetries: 0 }));

      socket.on('system:get_metrics', wrapHandler(socket, async () => {
        // Only allow admins to see metrics
        if (socket.user.role === 'Admin') {
          const combinedMetrics = {
            ...analytics.getMetrics(),
            simple_monitor: simpleMonitor.getMetrics()
          };
          emitWithErrorHandling(socket, 'system:metrics', combinedMetrics);
        } else {
          emitWithErrorHandling(socket, 'error', { 
            type: 'permission_denied',
            message: 'Admin access required' 
          });
        }
      }, { maxRetries: 0 }));

      // ===== DISCONNECT HANDLER =====
      socket.on('disconnect', (reason) => {
        console.log(`❌ User ${socket.user.username} disconnected: ${reason}`);
        
        try {
          // Clear health check interval
          if (socket.healthCheckInterval) {
            clearInterval(socket.healthCheckInterval);
          }
          
          // Track disconnection
          analytics.trackDisconnection(socket.user._id);

          const connection = activeConnections.get(socket.id);
          activeConnections.delete(socket.id);
          
          // Notify others in project rooms that user went offline
          if (connection && connection.rooms) {
            connection.rooms.forEach(room => {
              try {
                emitWithErrorHandling(socket, 'user:offline', {
                  user_id: socket.user._id,
                  username: socket.user.username,
                  timestamp: new Date(),
                  reason
                }, room);
              } catch (emitError) {
                console.error(`❌ Failed to emit user offline to room ${room}:`, emitError);
              }
            });
          }
        } catch (disconnectError) {
          console.error('❌ Error in disconnect handler:', disconnectError);
        }
      });

    } catch (connectionError) {
      console.error('❌ Error in connection handler:', connectionError);
      emitWithErrorHandling(socket, 'error', {
        type: 'connection_error',
        message: 'Failed to establish connection properly'
      });
    }
  });

  // Helper functions for external use
  const emitToProjectMembers = async (projectId, event, data, excludeUserId = null) => {
    try {
      const project = await Project.findById(projectId).populate('members', '_id');
      if (!project) return;

      project.members.forEach(member => {
        if (!excludeUserId || member._id.toString() !== excludeUserId.toString()) {
          try {
            io.to(`user_${member._id}`).emit(event, data);
          } catch (emitError) {
            console.error(`❌ Failed to emit to member ${member._id}:`, emitError);
          }
        }
      });
    } catch (error) {
      console.error('❌ Error emitting to project members:', error);
    }
  };

  const emitToUser = (userId, event, data) => {
    try {
      io.to(`user_${userId}`).emit(event, data);
      return true;
    } catch (error) {
      console.error(`❌ Failed to emit to user ${userId}:`, error);
      return false;
    }
  };

  const emitToProject = (projectId, event, data) => {
    try {
      io.to(`project_${projectId}`).emit(event, data);
      return true;
    } catch (error) {
      console.error(`❌ Failed to emit to project ${projectId}:`, error);
      return false;
    }
  };

  // Cleanup function for graceful shutdown
  const cleanup = () => {
    console.log('🧹 Cleaning up socket handlers...');
    
    // Clear all health check intervals
    activeConnections.forEach((connection, socketId) => {
      const socket = io.sockets.sockets.get(socketId);
      if (socket && socket.healthCheckInterval) {
        clearInterval(socket.healthCheckInterval);
      }
    });

    // Reset analytics
    analytics.reset();
    
    console.log('✅ Socket handlers cleanup completed');
  };

  // Export analytics for monitoring
  const getAnalytics = () => ({
    ...analytics.getMetrics(),
    simple_monitor: simpleMonitor.getMetrics()
  });
  
  const getActiveConnections = () => Array.from(activeConnections.values());

  // Graceful shutdown handling
  process.on('SIGTERM', cleanup);
  process.on('SIGINT', cleanup);

  console.log('✅ Socket handlers setup completed with built-in monitoring');

  return {
    emitToProjectMembers,
    emitToUser,
    emitToProject,
    getAnalytics,
    getActiveConnections,
    cleanup
  };
};

module.exports = setupSocketHandlers;