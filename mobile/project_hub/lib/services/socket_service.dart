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

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket?.connected == true) return;

    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.on('connect', (data) {
      print('✅ Socket connected');
    });

    _socket?.on('disconnect', (data) {
      print('❌ Socket disconnected');
    });

    _socket?.on('connect_error', (data) {
      print('🔴 Socket connection error: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // Task events
  void onTaskUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('task:update', (data) => callback(data));
  }

  void emitTaskUpdate(Map<String, dynamic> data) {
    _socket?.emit('task:update', data);
  }

  // Comment events
  void onNewComment(Function(Map<String, dynamic>) callback) {
    _socket?.on('comment:new', (data) => callback(data));
  }

  void emitNewComment(Map<String, dynamic> data) {
    _socket?.emit('comment:new', data);
  }

  // Notification events
  void onNewNotification(Function(Map<String, dynamic>) callback) {
    _socket?.on('notification:new', (data) => callback(data));
  }

  // Join/Leave rooms
  void joinProjectRoom(String projectId) {
    _socket?.emit('join', {'room': 'project_$projectId'});
  }

  void leaveProjectRoom(String projectId) {
    _socket?.emit('leave', {'room': 'project_$projectId'});
  }

  void joinUserRoom(String userId) {
    _socket?.emit('join', {'room': 'user_$userId'});
  }

  // Generic event listener
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
