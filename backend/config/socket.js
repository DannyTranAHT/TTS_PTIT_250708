const socketIO = require('socket.io');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const initializeSocket = (server) => {
  const io = socketIO(server, {
    cors: {
      origin: process.env.CLIENT_URL || "http://localhost:3000",
      methods: ["GET", "POST"]
    }
  });

  // Socket authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return next(new Error('User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${socket.user.username} connected`);

    // Join user to their personal room
    socket.join(`user_${socket.user._id}`);

    // Join project rooms based on user's projects
    // This would be implemented based on your project membership logic

    socket.on('disconnect', () => {
      console.log(`User ${socket.user.username} disconnected`);
    });
  });

  return io;
};

module.exports = initializeSocket;