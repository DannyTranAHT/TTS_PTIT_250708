// complete-realtime-test.js - Complete workflow để test realtime notifications
const { spawn } = require('child_process');
const axios = require('axios');

// ⚠️ CẤU HÌNH - THAY ĐỔI CÁC GIÁ TRỊ NÀY
const CONFIG = {
  // User 1 - Sender
  SENDER_TOKEN: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NzNkOTdiMGI3YmEzOTZjYTVjNGViMCIsImlhdCI6MTc1Mzc2ODI0MSwiZXhwIjoxNzU0MzczMDQxfQ.r8yQaUdbs1rwNmEPKZXbJQcPlf-2gzm7JXaCeeMrcYU',
  SENDER_USER_ID: '6873d97b0b7ba396ca5c4eb0',
  
  // User 2 - Receiver  
  RECEIVER_TOKEN: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NzNkYWJhMGI3YmEzOTZjYTVjNGViNCIsImlhdCI6MTc1Mzc3MTU4NSwiZXhwIjoxNzU0Mzc2Mzg1fQ.ei_FEJPB5gGZ6xigDlIb-We6nlrgKEtMd0OVjlWfHDk',
  RECEIVER_USER_ID: '6873daba0b7ba396ca5c4eb4',
  
  // Project
  PROJECT_ID: '68749d820f1d093cab3ab1dc',
  
  // Server
  SERVER_URL: 'http://localhost:5000'
};

class RealtimeTestOrchestrator {
  constructor() {
    this.senderClient = null;
    this.receiverClient = null;
    this.testResults = [];
  }

  log(message, type = 'INFO') {
    const timestamp = new Date().toISOString();
    const prefix = type === 'SUCCESS' ? '✅' : type === 'ERROR' ? '❌' : type === 'WARN' ? '⚠️' : 'ℹ️';
    console.log(`${prefix} [${timestamp}] ${message}`);
  }

  async validateConfig() {
    this.log('🔍 Validating configuration...');
    
    const requiredFields = ['SENDER_TOKEN', 'RECEIVER_TOKEN', 'SENDER_USER_ID', 'RECEIVER_USER_ID', 'PROJECT_ID'];
    const missing = requiredFields.filter(field => !CONFIG[field] || CONFIG[field].includes('_HERE'));
    
    if (missing.length > 0) {
      this.log(`Missing configuration: ${missing.join(', ')}`, 'ERROR');
      this.log('💡 Run: node get-database-ids.js to get IDs', 'WARN');
      this.log('💡 Login users to get JWT tokens', 'WARN');
      return false;
    }
    
    this.log('✅ Configuration validated', 'SUCCESS');
    return true;
  }

  async testNotificationAPI() {
    this.log('🔔 Testing notification API endpoints...');
    
    try {
      const api = axios.create({
        baseURL: `${CONFIG.SERVER_URL}/api`,
        headers: {
          'Authorization': `Bearer ${CONFIG.RECEIVER_TOKEN}`,
          'Content-Type': 'application/json'
        }
      });

      // Get initial unread count
      const initialCount = await api.get('/notifications/unread-count');
      this.log(`📊 Initial unread count: ${initialCount.data.count}`);
      
      return initialCount.data.count;
    } catch (error) {
      this.log(`❌ Notification API test failed: ${error.message}`, 'ERROR');
      return -1;
    }
  }

  startSocketClients() {
    this.log('🚀 Starting socket clients...');

    // Start receiver client (listener)
    this.receiverClient = spawn('node', ['-e', this.getReceiverClientCode()], {
      stdio: 'pipe',
      env: { ...process.env, ...CONFIG }
    });

    this.receiverClient.stdout.on('data', (data) => {
      console.log(`📱 RECEIVER: ${data.toString().trim()}`);
    });

    this.receiverClient.stderr.on('data', (data) => {
      console.error(`❌ RECEIVER ERROR: ${data.toString().trim()}`);
    });

    // Start sender client (after delay)
    setTimeout(() => {
      this.senderClient = spawn('node', ['-e', this.getSenderClientCode()], {
        stdio: 'pipe',
        env: { ...process.env, ...CONFIG }
      });

      this.senderClient.stdout.on('data', (data) => {
        console.log(`📤 SENDER: ${data.toString().trim()}`);
      });

      this.senderClient.stderr.on('data', (data) => {
        console.error(`❌ SENDER ERROR: ${data.toString().trim()}`);
      });
    }, 3000);
  }

  getSenderClientCode() {
    return `
      const { io } = require('socket.io-client');
      const socket = io('${CONFIG.SERVER_URL}', { auth: { token: '${CONFIG.SENDER_TOKEN}' } });
      
      socket.on('connect', () => {
        console.log('SENDER connected');
        
        // Join project
        setTimeout(() => {
          socket.emit('project:join', '${CONFIG.PROJECT_ID}');
        }, 1000);
        
        // Send private message
        setTimeout(() => {
          console.log('Sending private message...');
          socket.emit('message:private', {
            recipient_id: '${CONFIG.RECEIVER_USER_ID}',
            message: 'Test realtime message from sender!'
          });
        }, 3000);
        
        // Update task status
        setTimeout(() => {
          console.log('Updating task status...');
          socket.emit('task:status_update', {
            task_id: '${CONFIG.PROJECT_ID}',
            project_id: '${CONFIG.PROJECT_ID}',
            old_status: 'To Do',
            new_status: 'In Progress'
          });
        }, 5000);
        
        // Typing indicator
        setTimeout(() => {
          console.log('Starting typing...');
          socket.emit('comment:typing', {
            entity_type: 'Project',
            entity_id: '${CONFIG.PROJECT_ID}'
          });
        }, 7000);
        
        setTimeout(() => {
          console.log('Stopping typing...');
          socket.emit('comment:stop_typing', {
            entity_type: 'Project',
            entity_id: '${CONFIG.PROJECT_ID}'
          });
        }, 9000);
        
        // Disconnect after tests
        setTimeout(() => {
          console.log('SENDER disconnecting...');
          socket.disconnect();
          process.exit(0);
        }, 15000);
      });
      
      socket.on('connect_error', (error) => {
        console.error('SENDER connection error:', error.message);
        process.exit(1);
      });
    `;
  }

  getReceiverClientCode() {
    return `
      const { io } = require('socket.io-client');
      const socket = io('${CONFIG.SERVER_URL}', { auth: { token: '${CONFIG.RECEIVER_TOKEN}' } });
      
      let eventsReceived = [];
      
      socket.on('connect', () => {
        console.log('RECEIVER connected and listening...');
        socket.emit('project:join', '${CONFIG.PROJECT_ID}');
      });
      
      socket.on('project:user_joined', (data) => {
        console.log('📥 RECEIVED: User joined project');
        eventsReceived.push('project:user_joined');
      });
      
      socket.on('message:received', (data) => {
        console.log('📥 RECEIVED: Private message - ' + data.message);
        eventsReceived.push('message:received');
      });
      
      socket.on('task:status_updated', (data) => {
        console.log('📥 RECEIVED: Task status updated - ' + data.old_status + ' to ' + data.new_status);
        eventsReceived.push('task:status_updated');
      });
      
      socket.on('comment:user_typing', (data) => {
        console.log('📥 RECEIVED: User typing');
        eventsReceived.push('comment:user_typing');
      });
      
      socket.on('comment:user_stop_typing', (data) => {
        console.log('📥 RECEIVED: User stopped typing');
        eventsReceived.push('comment:user_stop_typing');
      });
      
      socket.on('notifications:count', (data) => {
        console.log('📥 RECEIVED: Notification count updated - ' + data.count);
        eventsReceived.push('notifications:count');
      });
      
      socket.on('connect_error', (error) => {
        console.error('RECEIVER connection error:', error.message);
        process.exit(1);
      });
      
      // Summary after 20 seconds
      setTimeout(() => {
        console.log('📊 RECEIVER SUMMARY:');
        console.log('Events received: ' + eventsReceived.length);
        console.log('Event types: ' + [...new Set(eventsReceived)].join(', '));
        socket.disconnect();
        process.exit(0);
      }, 20000);
    `;
  }

  async checkFinalNotifications() {
    this.log('🔍 Checking final notification counts...');
    
    setTimeout(async () => {
      try {
        const api = axios.create({
          baseURL: `${CONFIG.SERVER_URL}/api`,
          headers: {
            'Authorization': `Bearer ${CONFIG.RECEIVER_TOKEN}`,
            'Content-Type': 'application/json'
          }
        });

        const finalCount = await api.get('/notifications/unread-count');
        this.log(`📊 Final unread count: ${finalCount.data.count}`, 'SUCCESS');
        
        const notifications = await api.get('/notifications?limit=5');
        this.log(`📋 Latest notifications: ${notifications.data.notifications.length}`, 'SUCCESS');
        
        notifications.data.notifications.slice(0, 3).forEach((notif, index) => {
          this.log(`   ${index + 1}. [${notif.type}] ${notif.title}`);
        });

      } catch (error) {
        this.log(`❌ Final check failed: ${error.message}`, 'ERROR');
      }
    }, 25000);
  }

  cleanup() {
    this.log('🧹 Cleaning up...');
    if (this.senderClient) this.senderClient.kill();
    if (this.receiverClient) this.receiverClient.kill();
  }

  async run() {
    console.log('🔥 Starting Complete Realtime Notification Test\n');

    if (!(await this.validateConfig())) {
      process.exit(1);
    }

    await this.testNotificationAPI();
    this.startSocketClients();
    this.checkFinalNotifications();

    // Cleanup after 30 seconds
    setTimeout(() => {
      this.cleanup();
      this.log('🎉 Test completed!', 'SUCCESS');
      process.exit(0);
    }, 30000);

    // Handle interruption
    process.on('SIGINT', () => {
      this.cleanup();
      process.exit(0);
    });
  }
}

// Run the orchestrator
if (require.main === module) {
  const orchestrator = new RealtimeTestOrchestrator();
  orchestrator.run();
}

module.exports = RealtimeTestOrchestrator;