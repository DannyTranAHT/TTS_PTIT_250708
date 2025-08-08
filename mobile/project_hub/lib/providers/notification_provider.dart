import 'package:flutter/foundation.dart';
import '../services/notification_api_service.dart';
import '../services/socket_service.dart';
import 'package:project_hub/models/notification_model.dart';

enum NotificationState { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  List<Notification> _notifications = [];
  NotificationState _state = NotificationState.initial;
  String? _errorMessage;
  int _unreadCount = 0;

  // Getters
  List<Notification> get notifications => _notifications;
  List<Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  NotificationState get state => _state;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  // Initialize notifications and socket listeners
  Future<void> initializeNotifications(String token) async {
    await loadNotifications(token);
    _setupSocketListeners();
  }

  // Load notifications from API
  Future<void> loadNotifications(String token) async {
    _notifications.clear();
    _unreadCount = 0;
    _setState(NotificationState.loading);

    try {
      final response = await NotificationApiService.getNotifications(
        token: token,
      );

      if (response.isSuccess && response.model != null) {
        if (response.model!.notifications.isNotEmpty) {
          _notifications = response.model!.notifications;
          _unreadCount = response.model!.unreadCount;
        }
        _setState(NotificationState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String token, String notificationId) async {
    _setState(NotificationState.loading);
    try {
      final response = await NotificationApiService.markAsRead(
        token: token,
        notificationId: notificationId,
      );

      if (response.isSuccess) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);

        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        _setState(NotificationState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Error marking notification as read: $e');
    } finally {
      _setState(NotificationState.loaded);
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String token) async {
    _setState(NotificationState.loading);
    try {
      final response = await NotificationApiService.markAllAsRead(token: token);

      if (response.isSuccess) {
        for (var notification in _notifications) {
          if (!notification.isRead) {
            notification = notification.copyWith(isRead: true);
          }
        }
        _unreadCount = 0;
        _setState(NotificationState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    } finally {
      _setState(NotificationState.loaded);
    }
  }

  // Delete notification
  Future<void> deleteNotification(String token, String notificationId) async {
    _setState(NotificationState.loading);
    try {
      final response = await NotificationApiService.deleteNotification(
        token: token,
        notificationId: notificationId,
      );

      if (response.isSuccess) {
        _notifications.removeWhere((n) => n.id == notificationId);
        if (_notifications.isEmpty) {
          _unreadCount = 0;
        } else {
          _unreadCount = _notifications.where((n) => !n.isRead).length;
        }
        _setState(NotificationState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Error deleting notification: $e');
    } finally {
      _setState(NotificationState.loaded);
    }
  }

  // Setup real-time socket listeners
  void _setupSocketListeners() {
    // Listen for new notifications
    SocketService.instance.onNewNotification((data) {
      try {
        final notification = Notification.fromJson(data);
        _notifications.insert(0, notification);

        if (!notification.isRead) {
          _unreadCount++;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing new notification: $e');
      }
    });

    // Listen for task assignments that create notifications
    SocketService.instance.on('task:assigned', (data) {
      // This will be handled by the notification:new event above
      debugPrint('Task assigned notification received');
    });

    // Listen for notification updates
    SocketService.instance.on('notification:updated', (data) {
      try {
        final updatedNotification = Notification.fromJson(data);
        final index = _notifications.indexWhere(
          (n) => n.id == updatedNotification.id,
        );

        if (index != -1) {
          final oldNotification = _notifications[index];
          _notifications[index] = updatedNotification;

          // Update unread count if read status changed
          if (oldNotification.isRead != updatedNotification.isRead) {
            if (updatedNotification.isRead) {
              _unreadCount =
                  (_unreadCount - 1).clamp(0, double.infinity).toInt();
            } else {
              _unreadCount++;
            }
          }

          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error updating notification: $e');
      }
    });
  }

  // Private methods
  void _setState(NotificationState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = NotificationState.error;
    notifyListeners();
  }
}
