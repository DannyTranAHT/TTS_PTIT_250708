// test-client-2.js - RECEIVER CLIENT (Employee/User nhận tin nhắn)
const { io } = require('socket.io-client');

const CLIENT_NAME = 'EMPLOYEE-RECEIVER';

// ⚠️ THAY ĐỔI: Token của user sẽ NHẬN tin nhắn
const TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NzNkYWJhMGI3YmEzOTZjYTVjNGViNCIsImlhdCI6MTc1Mzc3MTU4NSwiZXhwIjoxNzU0Mzc2Mzg1fQ.ei_FEJPB5gGZ6xigDlIb-We6nlrgKEtMd0OVjlWfHDk'; // Token của user nhận tin nhắn
const PROJECT_ID = '68749d820f1d093cab3ab1dc'; // Cùng project với sender

console.log(`🚀 Starting ${CLIENT_NAME}...`);
console.log(`📍 Server: http://localhost:5000`);
console.log(`🔑 Token: ${TOKEN.substring(0, 20)}...`);
console.log(`📁 Project ID: ${PROJECT_ID}`);

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
  
  // Auto join project để nhận realtime updates
  setTimeout(() => {
    console.log(`📤 Joining project: ${PROJECT_ID}`);
    socket.emit('project:join', PROJECT_ID);
  }, 1000);
});

socket.on('connect_error', (error) => {
  console.log(`❌ CONNECTION ERROR: ${error.message}`);
});

socket.on('disconnect', (reason) => {
  console.log(`🔌 ${CLIENT_NAME} DISCONNECTED: ${reason}`);
});

// ===== NHẬN TẤT CẢ REALTIME EVENTS =====

// 🏢 Project Events
socket.on('project:user_joined', (data) => {
  console.log(`\n🏢 [REALTIME] USER JOINED PROJECT:`);
  console.log(`   User: ${data.user.full_name} (${data.user.username})`);
  console.log(`   Message: ${data.message}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

socket.on('project:user_left', (data) => {
  console.log(`\n🏢 [REALTIME] USER LEFT PROJECT:`);
  console.log(`   User: ${data.user.full_name} (${data.user.username})`);
  console.log(`   Message: ${data.message}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

// 📋 Task Events
socket.on('task:status_updated', (data) => {
  console.log(`\n📋 [REALTIME] TASK STATUS UPDATED:`);
  console.log(`   Task ID: ${data.task_id}`);
  console.log(`   Status: ${data.old_status} → ${data.new_status}`);
  console.log(`   Updated by: ${data.updated_by}`);
  console.log(`   Time: ${data.timestamp}`);
});

// ✍️ Comment/Typing Events
socket.on('comment:user_typing', (data) => {
  console.log(`\n✍️ [REALTIME] USER TYPING:`);
  console.log(`   User: ${data.user.full_name}`);
  console.log(`   Entity: ${data.entity_type} (${data.entity_id})`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

socket.on('comment:user_stop_typing', (data) => {
  console.log(`\n✍️ [REALTIME] USER STOPPED TYPING:`);
  console.log(`   User ID: ${data.user_id}`);
  console.log(`   Entity: ${data.entity_type} (${data.entity_id})`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

// 💬 Message Events - QUAN TRỌNG NHẤT
socket.on('message:received', (data) => {
  console.log(`\n💬 [REALTIME] ✨ MESSAGE RECEIVED! ✨`);
  console.log(`   From: ${data.from.full_name} (${data.from.username})`);
  console.log(`   Message: "${data.message}"`);
  console.log(`   Time: ${data.timestamp}`);
  console.log(`   Sender ID: ${data.from._id}`);
  console.log('   🎉 PRIVATE MESSAGE DELIVERY SUCCESSFUL!');
});

// 👤 User Status Events
socket.on('user:status_changed', (data) => {
  console.log(`\n👤 [REALTIME] USER STATUS CHANGED:`);
  console.log(`   User: ${data.username}`);
  console.log(`   Status: ${data.status}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

socket.on('user:offline', (data) => {
  console.log(`\n👤 [REALTIME] USER WENT OFFLINE:`);
  console.log(`   User: ${data.username}`);
  console.log(`   Time: ${data.timestamp}`);
});

// 🔔 Notification Events
socket.on('notifications:count', (data) => {
  console.log(`\n🔔 [REALTIME] NOTIFICATION COUNT UPDATED:`);
  console.log(`   Unread count: ${data.count}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

// 💬 Comment Events (if any)
socket.on('comment:new', (data) => {
  console.log(`\n💬 [REALTIME] NEW COMMENT:`);
  console.log(`   Author: ${data.author}`);
  console.log(`   Entity: ${data.entity_type} - ${data.entity_name}`);
  console.log(`   Comment: ${data.comment.content}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

// ❌ Error Events
socket.on('error', (data) => {
  console.log(`\n❌ [ERROR] SOCKET ERROR:`);
  console.log(`   Message: ${data.message}`);
  console.log(`   Time: ${new Date().toISOString()}`);
});

// ===== TEST ACTIONS (Optional) =====
setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION] ${CLIENT_NAME} updating status to 'available'...`);
    socket.emit('user:status', 'available');
  }
}, 5000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION] ${CLIENT_NAME} starting typing...`);
    socket.emit('comment:typing', {
      entity_type: 'Project',
      entity_id: PROJECT_ID
    });
  }
}, 10000);

setTimeout(() => {
  if (socket.connected) {
    console.log(`\n📤 [ACTION] ${CLIENT_NAME} stopped typing...`);
    socket.emit('comment:stop_typing', {
      entity_type: 'Project',
      entity_id: PROJECT_ID
    });
  }
}, 12000);

// ===== GRACEFUL SHUTDOWN =====
const cleanup = () => {
  console.log(`\n👋 ${CLIENT_NAME} shutting down gracefully...`);
  if (socket.connected) {
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

// Keep alive - this client listens for events
console.log(`\n👂 ${CLIENT_NAME} is LISTENING for realtime events...`);
console.log('🔥 Ready to receive messages, notifications, and updates!');
console.log('⏹️  Press Ctrl+C to stop');

// Error handling
process.on('uncaughtException', (error) => {
  console.error(`🚨 UNCAUGHT EXCEPTION:`, error);
  cleanup();
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(`🚨 UNHANDLED REJECTION:`, reason);
  cleanup();
});