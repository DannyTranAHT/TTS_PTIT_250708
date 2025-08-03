// test-notification-api.js - Test notification REST API endpoints
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

// ⚠️ THAY ĐỔI: Token của user muốn check notifications
const USER_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NzNkYWJhMGI3YmEzOTZjYTVjNGViNCIsImlhdCI6MTc1Mzc3MTU4NSwiZXhwIjoxNzU0Mzc2Mzg1fQ.ei_FEJPB5gGZ6xigDlIb-We6nlrgKEtMd0OVjlWfHDk';

const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Authorization': `Bearer ${USER_TOKEN}`,
    'Content-Type': 'application/json'
  }
});

async function testNotificationAPI() {
  try {
    console.log('🔔 Testing Notification API...\n');

    // Test 1: Get all notifications
    console.log('📋 Test 1: Get all notifications');
    try {
      const response = await api.get('/notifications');
      console.log('✅ GET /notifications successful');
      console.log(`📊 Total notifications: ${response.data.notifications.length}`);
      console.log(`📖 Unread: ${response.data.notifications.filter(n => !n.is_read).length}`);
      console.log(`✅ Read: ${response.data.notifications.filter(n => n.is_read).length}`);
      
      if (response.data.notifications.length > 0) {
        console.log('\n📝 Latest notifications:');
        response.data.notifications.slice(0, 3).forEach((notif, index) => {
          console.log(`   ${index + 1}. [${notif.type}] ${notif.title}`);
          console.log(`      Message: ${notif.message}`);
          console.log(`      Read: ${notif.is_read ? '✅' : '❌'}`);
          console.log(`      Time: ${notif.created_at}`);
          console.log('');
        });
      }
    } catch (error) {
      console.log('❌ GET /notifications failed:', error.response?.data?.message || error.message);
    }

    // Test 2: Get unread count
    console.log('\n📊 Test 2: Get unread count');
    try {
      const response = await api.get('/notifications/unread-count');
      console.log('✅ GET /notifications/unread-count successful');
      console.log(`🔔 Unread count: ${response.data.count}`);
    } catch (error) {
      console.log('❌ GET /notifications/unread-count failed:', error.response?.data?.message || error.message);
    }

    // Test 3: Get only unread notifications
    console.log('\n📬 Test 3: Get unread notifications');
    try {
      const response = await api.get('/notifications?is_read=false');
      console.log('✅ GET /notifications?is_read=false successful');
      console.log(`📬 Unread notifications: ${response.data.notifications.length}`);
      
      if (response.data.notifications.length > 0) {
        console.log('\n📝 Unread notifications:');
        response.data.notifications.forEach((notif, index) => {
          console.log(`   ${index + 1}. [${notif.type}] ${notif.title}`);
          console.log(`      Message: ${notif.message}`);
          console.log(`      Time: ${notif.created_at}`);
          console.log('');
        });
      }
    } catch (error) {
      console.log('❌ GET /notifications?is_read=false failed:', error.response?.data?.message || error.message);
    }

    // Test 4: Mark notification as read (if there are unread notifications)
    console.log('\n✅ Test 4: Mark notification as read');
    try {
      const unreadResponse = await api.get('/notifications?is_read=false&limit=1');
      if (unreadResponse.data.notifications.length > 0) {
        const notificationId = unreadResponse.data.notifications[0]._id;
        console.log(`📝 Marking notification ${notificationId} as read...`);
        
        const markReadResponse = await api.patch(`/notifications/${notificationId}/read`);
        console.log('✅ PATCH /notifications/:id/read successful');
        console.log(`📄 Notification marked as read: ${markReadResponse.data.notification.title}`);
      } else {
        console.log('📭 No unread notifications to mark as read');
      }
    } catch (error) {
      console.log('❌ Mark as read failed:', error.response?.data?.message || error.message);
    }

    // Test 5: Mark all as read
    console.log('\n✅ Test 5: Mark all notifications as read');
    try {
      const markAllResponse = await api.patch('/notifications/mark-all-read');
      console.log('✅ PATCH /notifications/mark-all-read successful');
      console.log(`📊 Marked ${markAllResponse.data.modifiedCount} notifications as read`);
    } catch (error) {
      console.log('❌ Mark all as read failed:', error.response?.data?.message || error.message);
    }

    // Test 6: Get updated counts
    console.log('\n📊 Test 6: Get updated unread count');
    try {
      const response = await api.get('/notifications/unread-count');
      console.log('✅ GET /notifications/unread-count successful');
      console.log(`🔔 Updated unread count: ${response.data.count}`);
    } catch (error) {
      console.log('❌ GET /notifications/unread-count failed:', error.response?.data?.message || error.message);
    }

    console.log('\n🎉 Notification API testing completed!');

  } catch (error) {
    console.error('❌ Unexpected error:', error.message);
  }
}

// Helper function to create test notification (for development)
async function createTestNotification(recipientId) {
  try {
    console.log('\n🧪 Creating test notification...');
    
    // This would typically be done via socket events or internal service calls
    // For testing, you might need to use MongoDB directly or create via admin API
    
    console.log('💡 To create test notifications:');
    console.log('1. Send a private message via socket (message:private)');
    console.log('2. Update a task status via API');
    console.log('3. Add a comment to a project/task');
    console.log('4. Add/remove members from projects');
    
  } catch (error) {
    console.error('❌ Error creating test notification:', error.message);
  }
}

// Run the tests
if (require.main === module) {
  if (!USER_TOKEN || USER_TOKEN === 'USER_JWT_TOKEN_HERE') {
    console.log('❌ Please set USER_TOKEN in the script!');
    console.log('💡 Get token by: POST /api/auth/login');
    process.exit(1);
  }
  
  testNotificationAPI();
}

module.exports = { testNotificationAPI, createTestNotification };