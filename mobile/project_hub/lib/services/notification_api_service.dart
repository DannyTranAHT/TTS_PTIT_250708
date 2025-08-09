import 'package:project_hub/models/api_response.dart';

import '../config/api_config.dart';
import '../models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationApiService {
  // Get all notifications with pagination and filters
  static Future<ApiResponse<NotificationResponse>> getNotifications({
    required String token,
    int? page,
    int? limit,
  }) async {
    final uri = Uri.parse('${ApiConfig.notifications}');
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (queryParams.isNotEmpty) {
      uri.replace(queryParameters: queryParams);
    }
    try {
      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final notifications =
            (json['notifications'] as List)
                .map((e) => Notification.fromJson(e))
                .toList();
        final totalPages = json['totalPages'];
        final currentPage = json['currentPage'];
        final total = json['total'];
        final unreadCount = json['unreadCount'];
        return ApiResponse.success(
          model: NotificationResponse(
            notifications: notifications,
            totalPages: totalPages,
            currentPage: currentPage,
            total: total,
            unreadCount: unreadCount,
          ),
          message: "Notifications loaded successfully",
        );
      } else {
        return ApiResponse.error(message: "Failed to load notifications");
      }
    } catch (e) {
      return ApiResponse.error(message: "Error fetching notifications: $e");
    }
  }

  // Mark specific notification as read
  static Future<ApiResponse> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.notifications}/$notificationId/read'),
        headers: ApiConfig.authHeaders(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(
          message: data['message'] ?? "Notification marked as read",
        );
      } else {
        print("Error marking notification as read: ${response.body}");
        return ApiResponse.error(
          message: "Failed to mark notification as read",
        );
      }
    } catch (e) {
      print("Error marking notification as read: $e");
      return ApiResponse.error(
        message: "Error marking notification as read: $e",
      );
    }
  }

  // Mark all notifications as read
  static Future<ApiResponse> markAllAsRead({required String token}) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.notifications}/mark-all-read'),
        headers: ApiConfig.authHeaders(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(
          message: data['message'] ?? "All notifications marked as read",
        );
      } else {
        return ApiResponse.error(
          message: "Failed to mark all notifications as read",
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: "Error marking all notifications as read: $e",
      );
    }
  }

  // Delete specific notification
  static Future<ApiResponse<Map<String, dynamic>>> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.notifications}/$notificationId'),
        headers: ApiConfig.authHeaders(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(
          model: data,
          message: "Notification deleted successfully",
        );
      } else {
        return ApiResponse.error(message: "Failed to delete notification");
      }
    } catch (e) {
      return ApiResponse.error(message: "Error deleting notification: $e");
    }
  }
}
