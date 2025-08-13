const { createServer } = require('http');
const { Server } = require('socket.io');
const Client = require('socket.io-client');
const jwt = require('jsonwebtoken');

describe('Socket System Tests', () => {
  let io, serverSocket, clientSocket, httpServer;
  const testUser = {
    _id: 'test_user_id',
    username: 'testuser',
    full_name: 'Test User'
  };

  beforeAll((done) => {
    httpServer = createServer();
    io = new Server(httpServer, {
      cors: { origin: "*" }
    });

    // Mock authentication
    io.use((socket, next) => {
      socket.user = testUser;
      next();
    });

    httpServer.listen(() => {
      const port = httpServer.address().port;
      
      clientSocket = new Client(`http://localhost:${port}`, {
        auth: { token: 'test_token' }
      });
      
      io.on('connection', (socket) => {
        serverSocket = socket;
      });
      
      clientSocket.on('connect', done);
    });
  });

  afterAll(() => {
    io.close();
    clientSocket.close();
    httpServer.close();
  });

  test('should connect successfully', () => {
    expect(serverSocket).toBeDefined();
    expect(serverSocket.user).toEqual(testUser);
  });

  test('should emit notification correctly', (done) => {
    const testNotification = {
      id: 'test_notification_id',
      title: 'Test Notification',
      message: 'Test message',
      type: 'task_assigned'
    };

    clientSocket.on('notification:new', (data) => {
      expect(data.title).toBe(testNotification.title);
      expect(data.message).toBe(testNotification.message);
      expect(data.type).toBe(testNotification.type);
      done();
    });

    serverSocket.emit('notification:new', testNotification);
  });

  test('should handle project join', (done) => {
    const projectId = 'test_project_id';

    clientSocket.on('project:user_joined', (data) => {
      expect(data.user._id).toBe(testUser._id);
      expect(data.user.username).toBe(testUser.username);
      done();
    });

    serverSocket.emit('project:join', projectId);
    // Simulate another user joining
    setTimeout(() => {
      serverSocket.to(`project_${projectId}`).emit('project:user_joined', {
        user: testUser,
        message: `${testUser.full_name} joined the project`
      });
    }, 100);
  });

  test('should handle task assignment', (done) => {
    const taskData = {
      task: {
        _id: 'test_task_id',
        name: 'Test Task',
        description: 'Test Description'
      },
      assigned_by: 'Test Manager'
    };

    clientSocket.on('task:assigned', (data) => {
      expect(data.task.name).toBe(taskData.task.name);
      expect(data.assigned_by).toBe(taskData.assigned_by);
      done();
    });

    serverSocket.emit('task:assigned', taskData);
  });

  test('should handle private messages', (done) => {
    const messageData = {
      from: testUser,
      message: 'Hello, this is a test message',
      timestamp: new Date()
    };

    clientSocket.on('message:received', (data) => {
      expect(data.from.username).toBe(testUser.username);
      expect(data.message).toBe(messageData.message);
      done();
    });

    serverSocket.emit('message:received', messageData);
  });

  test('should update notification count', (done) => {
    const countData = { count: 5 };

    clientSocket.on('notifications:count', (data) => {
      expect(data.count).toBe(countData.count);
      done();
    });

    serverSocket.emit('notifications:count', countData);
  });
});