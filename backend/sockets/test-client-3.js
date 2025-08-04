const { io } = require('socket.io-client');

const CLIENT_NAME = 'EMPLOYEE-2';
const TOKEN = 'EMPLOYEE2_JWT_TOKEN_HERE';
const PROJECT_ID = '507f1f77bcf86cd799439011'; // Cùng project ID

const socket = io('http://localhost:5000', {
  auth: { token: TOKEN }
});

socket.on('connect', () => {
  console.log(`🔗 ${CLIENT_NAME} connected:`, socket.id);
  
  // Auto join project after 4 seconds
  setTimeout(() => {
    socket.emit('project:join', PROJECT_ID);
    console.log(`📤 ${CLIENT_NAME} joined project ${PROJECT_ID}`);
  }, 4000);
});

// Listen to all events
socket.on('project:user_joined', (data) => {
  console.log(`🏢 ${CLIENT_NAME} sees user joined:`, data);
});

socket.on('project:user_left', (data) => {
  console.log(`🏢 ${CLIENT_NAME} sees user left:`, data);
});

socket.on('task:status_updated', (data) => {
  console.log(`📋 ${CLIENT_NAME} sees task update:`, data);
});

socket.on('comment:user_typing', (data) => {
  console.log(`✍️ ${CLIENT_NAME} sees typing:`, data);
});

socket.on('message:received', (data) => {
  console.log(`💬 ${CLIENT_NAME} received message:`, data);
});

socket.on('user:offline', (data) => {
  console.log(`👤 ${CLIENT_NAME} sees user offline:`, data);
});

// Employee 2 actions
setTimeout(() => {
  console.log(`📤 ${CLIENT_NAME} updating task status...`);
  socket.emit('task:status_update', {
    task_id: '507f1f77bcf86cd799439013',
    project_id: PROJECT_ID,
    old_status: 'In Progress',
    new_status: 'Done'
  });
}, 8000);

setTimeout(() => {
  console.log(`📤 ${CLIENT_NAME} leaving project...`);
  socket.emit('project:leave', PROJECT_ID);
}, 10000);

process.on('SIGINT', () => {
  console.log(`\n👋 ${CLIENT_NAME} exiting...`);
  socket.disconnect();
  process.exit(0);
});
