require('dotenv').config();
const http = require('http');
const app = require('./app');
const connectDB = require('./config/database');
const setupSocketHandlers = require('./sockets/socketHandlers');

const PORT = process.env.PORT || 5000;

// Connect to database
connectDB();

// Create HTTP server
const server = http.createServer(app);

// Initialize Socket.IO
const socketIO = require('socket.io');
const io = socketIO(server, {
  cors: {
    origin: process.env.CLIENT_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  },
  // 🆕 PERFORMANCE OPTIMIZATIONS
  pingTimeout: 60000,
  pingInterval: 25000,
  upgradeTimeout: 10000,
  maxHttpBufferSize: 1e6, // 1MB
  allowEIO3: true
});

// Setup socket handlers and get utilities
const socketHandlers = setupSocketHandlers(io);

// Make io and socket utilities accessible in routes
app.set('io', io);
app.set('socketHandlers', socketHandlers); // 🆕 For monitoring

// 🆕 SOCKET MONITORING
let socketStats = {
  totalConnections: 0,
  totalDisconnections: 0,
  peakConnections: 0,
  startTime: new Date()
};

io.engine.on("connection_error", (err) => {
  console.log('❌ Socket.IO connection error:', {
    req: err.req,
    code: err.code,
    message: err.message,
    context: err.context,
  });
});

io.on('connection', (socket) => {
  socketStats.totalConnections++;
  const currentConnections = io.engine.clientsCount;
  if (currentConnections > socketStats.peakConnections) {
    socketStats.peakConnections = currentConnections;
  }
  
  socket.on('disconnect', () => {
    socketStats.totalDisconnections++;
  });
});

// 🆕 PERIODIC LOGGING
setInterval(() => {
  const stats = {
    ...socketStats,
    currentConnections: io.engine.clientsCount,
    uptime: process.uptime(),
    memory: process.memoryUsage()
  };
  console.log('📊 Socket Stats:', JSON.stringify(stats, null, 2));
}, 300000); // Every 5 minutes

// Graceful shutdown
const gracefulShutdown = () => {
  console.log('🛑 Graceful shutdown initiated...');
  
  // Close socket connections
  io.close(() => {
    console.log('🔌 Socket.IO closed');
  });
  
  server.close(() => {
    console.log('🌐 HTTP server closed');
    process.exit(0);
  });
  
  // Force close after 10 seconds
  setTimeout(() => {
    console.error('⏰ Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

server.listen(PORT, () => {
  console.log(`🚀 Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
  console.log(`🔌 Socket.IO ready for connections`);
  console.log(`📊 Monitoring available at /api/system/socket-health`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.log(`❌ Unhandled Rejection: ${err.message}`);
  server.close(() => {
    process.exit(1);
  });
});

// Handle SIGTERM and SIGINT
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// 🆕 EXPORT FOR TESTING
module.exports = { app, server, io };
