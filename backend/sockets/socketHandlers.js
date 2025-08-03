const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Project = require('../models/Project');
const { createNotification } = require('../services/notificationService');

const setupSocketHandlers = (io) => {
  // Socket authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user || !user.is_active) {
        return next(new Error('User not found or inactive'));
      }

      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', async (socket) => {
    console.log(`User ${socket.user.username} connected with socket ${socket.id}`);

    // Join user to their personal room
    socket.join(`user_${socket.user._id}`);

    // Join user to their project rooms
    try {
      const userProjects = await Project.find({
        $or: [
          { owner_id: socket.user._id },
          { members: socket.user._id }
        ],
        is_archived: false
      }).select('_id name');

      userProjects.forEach(project => {
        socket.join(`project_${project._id}`);
      });

      console.log(`User ${socket.user.username} joined ${userProjects.length} project rooms`);
    } catch (error) {
      console.error('Error joining project rooms:', error);
    }

    // Handle user status updates
    socket.on('user:status', (status) => {
      socket.broadcast.to(`user_${socket.user._id}`).emit('user:status_changed', {
        user_id: socket.user._id,
        username: socket.user.username,
        status
      });
    });

    // Handle project-specific events
    socket.on('project:join', (projectId) => {
      socket.join(`project_${projectId}`);
      socket.to(`project_${projectId}`).emit('project:user_joined', {
        user: {
          _id: socket.user._id,
          username: socket.user.username,
          full_name: socket.user.full_name
        },
        message: `${socket.user.full_name} joined the project`
      });
    });

    socket.on('project:leave', (projectId) => {
      socket.leave(`project_${projectId}`);
      socket.to(`project_${projectId}`).emit('project:user_left', {
        user: {
          _id: socket.user._id,
          username: socket.user.username,
          full_name: socket.user.full_name
        },
        message: `${socket.user.full_name} left the project`
      });
    });

    // Handle task status updates in real-time
    socket.on('task:status_update', (data) => {
      const { task_id, project_id, old_status, new_status } = data;
      
      socket.to(`project_${project_id}`).emit('task:status_updated', {
        task_id,
        old_status,
        new_status,
        updated_by: socket.user.full_name,
        timestamp: new Date()
      });
    });

    // Handle typing indicators for comments
    socket.on('comment:typing', (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('comment:user_typing', {
        entity_type,
        entity_id,
        user: {
          _id: socket.user._id,
          full_name: socket.user.full_name
        }
      });
    });

    socket.on('comment:stop_typing', (data) => {
      const { entity_type, entity_id } = data;
      socket.broadcast.emit('comment:user_stop_typing', {
        entity_type,
        entity_id,
        user_id: socket.user._id
      });
    });

    // Handle private messages (FIXED VERSION)
    socket.on('message:private', async (data) => {
      const { recipient_id, message } = data;
      
      // ✅ Validate recipient_id is a valid ObjectId
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

      // ✅ Create notification với enum values có sẵn trong schema
      try {
        await createNotification({
          user_id: recipient_id, // ✅ Sử dụng ObjectId thực
          type: 'comment_added', // ✅ Sử dụng enum có sẵn thay vì 'message_received'
          title: 'New Message',
          message: `${socket.user.full_name} sent you a message`,
          related_entity: {
            entity_type: 'Comment', // ✅ Sử dụng enum có sẵn thay vì 'User'
            entity_id: socket.user._id
          }
        });
      } catch (notificationError) {
        console.error('Error creating notification:', notificationError);
        // Don't break the message flow even if notification fails
      }
    });

    // Handle disconnect
    socket.on('disconnect', (reason) => {
      console.log(`User ${socket.user.username} disconnected: ${reason}`);
      
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

    // Send initial notification count
    try {
      const { getUnreadCount } = require('../services/notificationService');
      const unreadCount = await getUnreadCount(socket.user._id);
      socket.emit('notifications:count', { count: unreadCount });
    } catch (error) {
      console.error('Error sending initial notification count:', error);
    }
  });

  // Helper function to emit to project members
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

  // Helper function to emit to specific user
  const emitToUser = (userId, event, data) => {
    io.to(`user_${userId}`).emit(event, data);
  };

  // Helper function to emit to project room
  const emitToProject = (projectId, event, data) => {
    io.to(`project_${projectId}`).emit(event, data);
  };

  return {
    emitToProjectMembers,
    emitToUser,
    emitToProject
  };
};

module.exports = setupSocketHandlers;