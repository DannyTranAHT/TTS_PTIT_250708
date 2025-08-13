import 'dart:async';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;

  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  // STREAMS FOR REACTIVE PROGRAMMING
  final StreamController<int> _notificationCountController =
      StreamController<int>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _taskController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _projectController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  // RECONNECTION LOGIC
  Timer? _reconnectionTimer;
  int _reconnectionAttempts = 0;
  final int _maxReconnectionAttempts = 5;
  String? _lastToken;

  //  GETTERS FOR STREAMS
  Stream<int> get notificationCountStream =>
      _notificationCountController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get taskStream => _taskController.stream;
  Stream<Map<String, dynamic>> get projectStream => _projectController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  //  ENHANCED CONNECTION WITH RETRY LOGIC
  void connect(String token) {
    if (_socket?.connected == true) return;

    _lastToken = token;
    _reconnectionAttempts = 0;

    print('🔌 Connecting to socket server...');

    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(_maxReconnectionAttempts)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token})
          .build(),
    );

    _setupEventListeners();
  }

  // CENTRALIZED EVENT LISTENER SETUP
  void _setupEventListeners() {
    // ===== CONNECTION EVENTS =====
    _socket?.on('connect', (data) {
      print(' Socket connected: ${_socket?.id}');
      _connectionStatusController.add(true);
      _reconnectionAttempts = 0;
      _reconnectionTimer?.cancel();
    });

    _socket?.on('disconnect', (reason) {
      print(' Socket disconnected: $reason');
      _connectionStatusController.add(false);

      if (reason != 'io server disconnect') {
        _attemptReconnection();
      }
    });

    _socket?.on('connect_error', (error) {
      print('Socket connection error: $error');
      _connectionStatusController.add(false);
      _attemptReconnection();
    });

    _socket?.on('reconnect', (attemptNumber) {
      print('Socket reconnected after $attemptNumber attempts');
      _connectionStatusController.add(true);
    });

    // ===== NOTIFICATION EVENTS =====
    _socket?.on('notification:new', (data) {
      print('New notification: ${data['title']}');
      _notificationController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('notifications:count', (data) {
      print('Notification count: ${data['count']}');
      _notificationCountController.add(data['count'] ?? 0);
    });

    _socket?.on('notification:marked_read', (data) {
      print('Notification marked as read: ${data['notification_id']}');
    });

    _socket?.on('notifications:all_marked_read', (data) {
      print('All notifications marked as read');
      _notificationCountController.add(0);
    });

    _socket?.on('notification:deleted', (data) {
      print(' Notification deleted: ${data['notification_id']}');
    });

    _socket?.on('notifications:batch_marked_read', (data) {
      print(' Batch notifications marked as read: ${data['count']}');
    });

    // ===== TASK EVENTS =====
    _socket?.on('task:assigned', (data) {
      print(' Task assigned: ${data['task']['name']}');
      _taskController.add({
        'type': 'assigned',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('task:updated', (data) {
      print(' Task updated: ${data['task']['name']}');
      _taskController.add({
        'type': 'updated',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('task:completion_requested', (data) {
      print(' Task completion requested: ${data['task']['name']}');
      _taskController.add({
        'type': 'completion_requested',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('task:status_updated', (data) {
      print(
        ' Task status updated: ${data['old_status']} → ${data['new_status']}',
      );
      _taskController.add({
        'type': 'status_updated',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('task:created', (data) {
      print(' Task created: ${data['task']['name']}');
      _taskController.add({
        'type': 'created',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('task:project_updated', (data) {
      print(' Project task updated: ${data['task_name']}');
      _taskController.add({
        'type': 'project_updated',
        'data': Map<String, dynamic>.from(data),
      });
    });

    // ===== PROJECT EVENTS =====
    _socket?.on('project:user_joined', (data) {
      print(' User joined project: ${data['user']['full_name']}');
      _projectController.add({
        'type': 'user_joined',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('project:user_left', (data) {
      print(' User left project: ${data['user']['full_name']}');
      _projectController.add({
        'type': 'user_left',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('project:member_added', (data) {
      print(' Member added: ${data['new_member']['full_name']}');
      _projectController.add({
        'type': 'member_added',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('project:member_removed', (data) {
      print('You were removed from project: ${data['project_name']}');
      _projectController.add({
        'type': 'member_removed',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('project:member_left', (data) {
      print(' Member left: ${data['removed_member']['full_name']}');
      _projectController.add({
        'type': 'member_left',
        'data': Map<String, dynamic>.from(data),
      });
    });

    _socket?.on('project:joined', (data) {
      print(' You joined project: ${data['project_name']}');
      _projectController.add({
        'type': 'joined',
        'data': Map<String, dynamic>.from(data),
      });
    });

    // ===== MESSAGE EVENTS =====
    _socket?.on('message:received', (data) {
      print(' Message from ${data['from']['full_name']}: ${data['message']}');
      _messageController.add({
        'type': 'received',
        'data': Map<String, dynamic>.from(data),
      });
    });

    // ===== USER EVENTS =====
    _socket?.on('user:status_changed', (data) {
      print(' User status changed: ${data['username']} → ${data['status']}');
    });

    _socket?.on('user:offline', (data) {
      print(' User went offline: ${data['username']}');
    });

    _socket?.on('user:typing', (data) {
      print('User typing: ${data['user']['full_name']}');
    });

    _socket?.on('user:stop_typing', (data) {
      print('User stopped typing: ${data['user_id']}');
    });

    // ===== COMMENT EVENTS =====
    _socket?.on('comment:new', (data) {
      print('New comment from ${data['author']}');
    });

    _socket?.on('comment:user_typing', (data) {
      print('Comment typing: ${data['user']['full_name']}');
    });

    _socket?.on('comment:user_stop_typing', (data) {
      print('Comment stopped typing');
    });

    // ===== SYSTEM EVENTS =====
    _socket?.on('system:pong', (data) {
      print('Pong received: ${data['server_time']}');
    });

    _socket?.on('error', (data) {
      print('Socket error: ${data['message']}');
    });
  }

  // RECONNECTION LOGIC
  void _attemptReconnection() {
    if (_reconnectionAttempts >= _maxReconnectionAttempts) {
      print('❌ Max reconnection attempts reached');
      return;
    }

    _reconnectionAttempts++;
    final delay = Duration(seconds: _reconnectionAttempts * 2);

    print('Reconnection attempt $_reconnectionAttempts in ${delay.inSeconds}s');

    _reconnectionTimer = Timer(delay, () {
      if (_lastToken != null) {
        disconnect();
        connect(_lastToken!);
      }
    });
  }

  // ===== EMIT METHODS =====

  // Notification Actions
  void markNotificationAsRead(String notificationId) {
    _socket?.emit('notifications:mark_read', {
      'notification_id': notificationId,
    });
  }

  void markAllNotificationsAsRead() {
    _socket?.emit('notifications:mark_all_read');
  }

  void deleteNotification(String notificationId) {
    _socket?.emit('notifications:delete', {'notification_id': notificationId});
  }

  // Project Actions
  void joinProjectRoom(String projectId) {
    _socket?.emit('project:join', projectId);
  }

  void leaveProjectRoom(String projectId) {
    _socket?.emit('project:leave', projectId);
  }

  // Task Actions
  void updateTaskStatus(Map<String, dynamic> data) {
    _socket?.emit('task:status_update', data);
  }

  void emitTaskUpdate(Map<String, dynamic> data) {
    _socket?.emit('task:update', data);
  }

  // Comment Actions
  void startTyping(String entityType, String entityId) {
    _socket?.emit('user:typing_start', {
      'entity_type': entityType,
      'entity_id': entityId,
    });
  }

  void stopTyping(String entityType, String entityId) {
    _socket?.emit('user:typing_stop', {
      'entity_type': entityType,
      'entity_id': entityId,
    });
  }

  void emitNewComment(Map<String, dynamic> data) {
    _socket?.emit('comment:new', data);
  }

  // User Actions
  void setUserStatus(String status) {
    _socket?.emit('user:set_status', {'status': status});
  }

  // Message Actions
  void sendPrivateMessage(String recipientId, String message) {
    _socket?.emit('message:private', {
      'recipient_id': recipientId,
      'message': message,
    });
  }

  // ⚙️ System Actions
  void ping() {
    _socket?.emit('system:ping');
  }

  void getMetrics() {
    _socket?.emit('system:get_metrics');
  }

  // ===== LEGACY COMPATIBILITY =====
  void onTaskUpdate(Function(Map<String, dynamic>) callback) {
    taskStream.listen((event) {
      if (event['type'] == 'updated') {
        callback(event['data']);
      }
    });
  }

  void onNewComment(Function(Map<String, dynamic>) callback) {
    _socket?.on('comment:new', (data) => callback(data));
  }

  void onNewNotification(Function(Map<String, dynamic>) callback) {
    notificationStream.listen(callback);
  }

  // ===== GENERIC METHODS =====
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void off(String event) {
    _socket?.off(event);
  }

  // ENHANCED DISCONNECT
  void disconnect() {
    print('🔌 Disconnecting socket...');
    _reconnectionTimer?.cancel();
    _socket?.disconnect();
    _socket = null;
    _connectionStatusController.add(false);
  }

  // MANUAL RECONNECTION
  void reconnect() {
    if (_lastToken != null) {
      disconnect();
      connect(_lastToken!);
    }
  }

  // CLEANUP RESOURCES
  void dispose() {
    disconnect();
    _notificationCountController.close();
    _notificationController.close();
    _connectionStatusController.close();
    _taskController.close();
    _projectController.close();
    _messageController.close();
  }
}
