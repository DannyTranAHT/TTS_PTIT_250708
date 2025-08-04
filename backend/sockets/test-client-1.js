// test-client-1.js
const { io } = require('socket.io-client');

const CLIENT_NAME = 'MANAGER';

// ⚠️ THAY ĐỔI CÁC GIÁ TRỊ NÀY BẰNG DỮ LIỆU THỰC TỪ DATABASE
const TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NzNkOTdiMGI3YmEzOTZjYTVjNGViMCIsImlhdCI6MTc1Mzc2ODI0MSwiZXhwIjoxNzU0MzczMDQxfQ.r8yQaUdbs1rwNmEPKZXbJQcPlf-2gzm7JXaCeeMrcYU'; // Lấy từ POST /api/auth/login
const PROJECT_ID = '68749d820f1d093cab3ab1dc'; // Lấy từ db.projects.find()
const RECIPIENT_USER_ID = '6873daba0b7ba396ca5c4eb4'; // Lấy từ db.users.find()

console.log(`🚀 Starting ${CLIENT_NAME}...`);
console.log(`📍 Server: http://localhost:5000`);
console.log(`🔑 Token: ${TOKEN.substring(0, 20)}...`);
console.log(`📁 Project ID: ${PROJECT_ID}`);
console.log(`👤 Recipient ID: ${RECIPIENT_USER_ID}`);

const socket = io('http://localhost:5000', {
  auth: { token: TOKEN },
  forceNew: true,
  reconnection: true,
  timeout: 5000,
  transports: ['websocket']
});

// ===== CONNECTION EVENTS =====
socket.on('connect', () => {
  console.log(`✅ ${CLIENT_NAME} CONNECTED successfully!`);
  console.log(`🆔 Socket ID: ${socket.id}`);
  
  // Auto join project
  setTimeout(() => {
    console.log(`📤 Joining project: ${PROJECT_ID}`);
    socket.emit('project:join', PROJECT_ID);
  }, 1000);
});

socket.on('connect_error', (error) => {
  console.log(`❌ CONNECTION ERROR: ${error.message}`);
  if (error.message.includes('Authentication error')) {
    console.log('🔑 Check your JWT token!');
  }
});

socket.on('disconnect', (reason) => {
  console.log(`🔌 ${CLIENT_NAME} DISCONNECTED: ${reason}`);
});

socket.on('reconnect', (attemptNumber) => {
  console.log(`🔄 RECONNECTED after ${attemptNumber} attempts`);
});

// ===== PROJECT EVENTS =====
socket.on('project:user_joined', (data) => {
  console.log(`🏢✅ PROJECT USER JOINED:`);
  console.log(JSON.stringify(data, null, 2));
});

socket.on('project:user_left', (data) => {
  console.log(`🏢❌ PROJECT USER LEFT:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== TASK EVENTS =====
socket.on('task:status_updated', (data) => {
  console.log(`📋✅ TASK STATUS UPDATED:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== COMMENT EVENTS =====
socket.on('comment:user_typing', (data) => {
  console.log(`✍️ USER TYPING:`);
  console.log(JSON.stringify(data, null, 2));
});

socket.on('comment:user_stop_typing', (data) => {
  console.log(`✍️❌ USER STOPPED TYPING:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== MESSAGE EVENTS =====
socket.on('message:received', (data) => {
  console.log(`💬✅ MESSAGE RECEIVED:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== STATUS EVENTS =====
socket.on('user:status_changed', (data) => {
  console.log(`👤✅ USER STATUS CHANGED:`);
  console.log(JSON.stringify(data, null, 2));
});

socket.on('user:offline', (data) => {
  console.log(`👤❌ USER WENT OFFLINE:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== NOTIFICATION EVENTS =====
socket.on('notifications:count', (data) => {
  console.log(`🔔 NOTIFICATION COUNT:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== ERROR EVENTS =====
socket.on('error', (data) => {
  console.log(`❌ SOCKET ERROR:`);
  console.log(JSON.stringify(data, null, 2));
});

// ===== AUTOMATED ACTIONS =====
setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 1] Updating user status...`);
    socket.emit('user:status', 'busy');
  }
}, 3000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 2] Updating task status...`);
    socket.emit('task:status_update', {
      task_id: PROJECT_ID, // Sử dụng project ID làm task ID test
      project_id: PROJECT_ID,
      old_status: 'To Do',
      new_status: 'In Progress'
    });
  }
}, 5000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 3] Starting typing indicator...`);
    socket.emit('comment:typing', {
      entity_type: 'Project',
      entity_id: PROJECT_ID
    });
  }
}, 7000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 4] Stopping typing indicator...`);
    socket.emit('comment:stop_typing', {
      entity_type: 'Project',
      entity_id: PROJECT_ID
    });
  }
}, 9000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 5] Sending private message...`);
    socket.emit('message:private', {
      recipient_id: RECIPIENT_USER_ID, // ✅ Phải là ObjectId thực 24 characters
      message: 'Hello from Manager! This is a test message.'
    });
  }
}, 11000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION 6] Leaving project...`);
    socket.emit('project:leave', PROJECT_ID);
  }
}, 13000);

// ===== GRACEFUL SHUTDOWN =====
const cleanup = () => {
  console.log(`\n👋 ${CLIENT_NAME} shutting down gracefully...`);
  if (socket.connected) {
    console.log(`📤 Leaving project...`);
    socket.emit('project:leave', PROJECT_ID);
    
    setTimeout(() => {
      socket.disconnect();
      process.exit(0);
    }, 1000);
  } else {
    process.exit(0);
  }
};

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);

// Auto-exit after 20 seconds
setTimeout(() => {
  console.log(`\n⏰ Auto-exiting after 20 seconds...`);
  cleanup();
}, 20000);

// ===== ERROR HANDLING =====
process.on('uncaughtException', (error) => {
  console.error(`🚨 UNCAUGHT EXCEPTION:`, error);
  cleanup();
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(`🚨 UNHANDLED REJECTION:`, reason);
  cleanup();
});