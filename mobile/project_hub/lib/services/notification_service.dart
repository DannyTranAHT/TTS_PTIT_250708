import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'socket_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static final StreamController<Map<String, dynamic>> _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  static Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapController.stream;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
        if (response.payload != null) {
          _notificationTapController.add({
            'payload': response.payload,
            'actionId': response.actionId,
          });
        }
      },
    );

    // Setup socket notification listener
    _setupSocketNotificationListener();
  }

  static void _setupSocketNotificationListener() {
    SocketService.instance.notificationStream.listen((notification) {
      showNotification(
        title: notification['title'] ?? 'New Notification',
        body: notification['message'] ?? '',
        payload: notification['id']?.toString(),
        type: notification['type'],
      );
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? type,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'project_hub_channel',
      'Project Hub Notifications',
      channelDescription: 'Notifications for Project Hub app',
      importance: Importance.high,
      priority: Priority.high,
      icon: _getNotificationIcon(type),
      color: _getNotificationColor(type),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static String? _getNotificationIcon(String? type) {
    switch (type) {
      case 'task_assigned':
        return '@drawable/ic_task';
      case 'comment_added':
        return '@drawable/ic_comment';
      case 'project_updated':
        return '@drawable/ic_project';
      default:
        return '@mipmap/ic_launcher';
    }
  }

  static Color _getNotificationColor(String? type) {
    switch (type) {
      case 'task_assigned':
        return Colors.blue;
      case 'comment_added':
        return Colors.green;
      case 'project_updated':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}