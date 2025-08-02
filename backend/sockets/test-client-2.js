const { io } = require('socket.io-client');

const CLIENT_NAME = 'EMPLOYEE-1';
const TOKEN = 'EMPLOYEE1_JWT_TOKEN_HERE';
const PROJECT_ID = '507f1f77bcf86cd799439011'; // Cùng project ID

const socket = io('http://localhost:5000', {
  auth: { token: TOKEN }
});

socket.on('connect', () => {
  console.log(`🔗 ${CLIENT_NAME} connected:`, socket.id);
  
  // Auto join project after 2 seconds
  setTimeout(() => {
    socket.emit('project:join', PROJECT_ID);
    console.log(`📤 ${CLIENT_NAME} joined project ${PROJECT_ID}`);
  }, 2000);
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

// Employee 1 actions
setTimeout(() => {
  console.log(`📤 ${CLIENT_NAME} starting typing...`);
  socket.emit('comment:typing', {
    entity_type: 'Task',
    entity_id: '507f1f77bcf86cd799439012'
  });
}, 4000);

setTimeout(() => {
  console.log(`📤 ${CLIENT_NAME} stopped typing...`);
  socket.emit('comment:stop_typing', {
    entity_type: 'Task',
    entity_id: '507f1f77bcf86cd799439012'
  });
}, 6000);

setTimeout(() => {
  console.log(`📤 ${CLIENT_NAME} updating status...`);
  socket.emit('user:status', 'busy');
}, 7000);

process.on('SIGINT', () => {
  console.log(`\n👋 ${CLIENT_NAME} exiting...`);
  socket.disconnect();
  process.exit(0);
});
