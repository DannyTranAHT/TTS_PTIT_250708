import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/screens/notifications/notification_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:project_hub/models/notification_model.dart' as custom;
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../widgets/top_bar.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    token = authProvider.token;

    if (token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.initializeNotifications(token!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                TopBar(isBack: true),

                _buildHeader(),

                Expanded(
                  child: Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      return _buildNotificationsList(notificationProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 4.h),
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      // Unread count
                      if (provider.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            '${provider.unreadCount} chưa đọc',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 24.sp),
                onSelected: (value) {
                  if (value == 'mark_all_read') {
                    if (token != null) {
                      provider.markAllAsRead(token!);
                    }
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            Icon(Icons.done_all, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text('Đánh dấu tất cả đã đọc'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationProvider provider) {
    if (provider.state == NotificationState.loading &&
        provider.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (provider.state == NotificationState.error) {
      return _buildErrorState(provider.errorMessage ?? 'Có lỗi xảy ra');
    }

    if (provider.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(token!),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          if (index == provider.notifications.length) {
            return _buildLoadingMore();
          }

          final notification = provider.notifications[index];
          return _buildNotificationItem(notification, provider);
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    custom.Notification notification,
    NotificationProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? Colors.white
                : Color(0xFF6C63FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey[200]!
                  : Color(0xFF6C63FF).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ListTile(
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              timeago.format(notification.createdAt, locale: 'vi'),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
            if (!notification.isRead) ...[
              SizedBox(width: 8.w),
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
          onSelected:
              (value) =>
                  _handleNotificationAction(value, notification, provider),
          itemBuilder:
              (context) => [
                if (!notification.isRead)
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text('Đánh dấu đã đọc'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _handleNotificationTap(notification, provider),
      ),
    );
  }

  Widget _buildNotificationIcon(custom.Notification notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'task_assigned':
        iconData = Icons.assignment;
        iconColor = Colors.blue;
        break;
      case 'task_updated':
        iconData = Icons.task_alt;
        iconColor = Colors.orange;
        break;
      case 'project_updated':
        iconData = Icons.folder;
        iconColor = Colors.green;
        break;
      case 'comment_added':
        iconData = Icons.comment;
        iconColor = Colors.purple;
        break;
      case 'due_date_reminder':
        iconData = Icons.schedule;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20.sp),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6C63FF)),
          SizedBox(height: 16.h),
          Text(
            'Đang tải thông báo...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              if (token != null) {
                final provider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                provider.loadNotifications(token!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bạn sẽ thấy các thông báo mới tại đây',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: EdgeInsets.all(16.w),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: Color(0xFF6C63FF),
        strokeWidth: 2.0,
      ),
    );
  }

  void _handleNotificationAction(
    String action,
    custom.Notification notification,
    NotificationProvider provider,
  ) {
    switch (action) {
      case 'mark_read':
        if (token != null) {
          provider.markAsRead(token!, notification.id);
        }
        break;
      case 'delete':
        _showDeleteDialog(notification, provider);
        break;
    }
  }

  Future<void> _handleNotificationTap(
    custom.Notification notification,
    NotificationProvider provider,
  ) async {
    // Navigate to notification detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  void _showDeleteDialog(
    custom.Notification notification,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xóa thông báo'),
            content: Text('Bạn có chắc muốn xóa thông báo này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (token != null) {
                    provider.deleteNotification(token!, notification.id);
                  }
                  Navigator.pop(context);
                },
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
