import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/notification_model.dart' as custom;
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../project/project_detail.dart';
import '../task/task_detail.dart';

class NotificationDetailScreen extends StatefulWidget {
  final custom.Notification notification;

  const NotificationDetailScreen({Key? key, required this.notification})
    : super(key: key);

  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  String? token;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    token = authProvider.token;

    // Mark as read when viewing detail
    if (!widget.notification.isRead && token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.markAsRead(token!, widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Notification Header Card
            _buildNotificationHeader(),

            SizedBox(height: 16.h),

            // Notification Content Card
            _buildNotificationContent(),

            SizedBox(height: 16.h),

            // Related Entity Card (if exists)
            if (widget.notification.relatedEntity != null)
              _buildRelatedEntityCard(),

            SizedBox(height: 16.h),

            // Action Buttons
            _buildActionButtons(),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Chi tiết thông báo',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Notification Icon
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: _getNotificationColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(),
              color: _getNotificationColor(),
              size: 28.sp,
            ),
          ),

          SizedBox(width: 16.w),

          // Notification Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.notification.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 8.h),
                // Read Status
                Row(
                  children: [
                    Icon(
                      widget.notification.isRead
                          ? Icons.mark_email_read
                          : Icons.mark_email_unread,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.notification.isRead ? 'Đã đọc' : 'Chưa đọc',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      timeago.format(
                        widget.notification.createdAt,
                        locale: 'vi',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Nội dung thông báo',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),

          SizedBox(height: 16.h),
          // Message
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.notification.message,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Color(0xFF2D2D2D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Timestamp Details
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16.sp, color: Color(0xFF6C63FF)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian nhận:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${widget.notification.createdAt.day}/${widget.notification.createdAt.month}/${widget.notification.createdAt.year} lúc ${widget.notification.createdAt.hour}:${widget.notification.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedEntityCard() {
    final entity = widget.notification.relatedEntity!;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _navigateToRelatedEntity,
        icon:
            isLoading
                ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
                : Icon(
                  entity.entityType == 'Task' ? Icons.task_alt : Icons.folder,
                  size: 18.sp,
                ),
        label: Text(
          isLoading
              ? 'Đang tải...'
              : 'Xem chi tiết ${entity.entityType == 'Task' ? 'Task' : 'Dự án'}',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Delete Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showDeleteDialog,
              icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
              label: Text(
                'Xóa thông báo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          if (errorMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 13.sp, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for notification styling
  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case 'task_assigned':
        return Icons.assignment;
      case 'task_updated':
        return Icons.task_alt;
      case 'project_updated':
        return Icons.folder;
      case 'comment_added':
        return Icons.comment;
      case 'due_date_reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    switch (widget.notification.type) {
      case 'task_assigned':
        return Colors.blue;
      case 'task_updated':
        return Colors.orange;
      case 'project_updated':
        return Colors.green;
      case 'comment_added':
        return Colors.purple;
      case 'due_date_reminder':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _navigateToRelatedEntity() async {
    if (widget.notification.relatedEntity == null || token == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final entity = widget.notification.relatedEntity!;

      if (entity.entityType == 'Task') {
        final task = await Provider.of<TaskProvider>(
          context,
          listen: false,
        ).fetchTaskById(token: token!, taskId: entity.entityId);

        if (task != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Không thể tải thông tin task';
          });
        }
      } else if (entity.entityType == 'Project') {
        final project = await Provider.of<ProjectProvider>(
          context,
          listen: false,
        ).fetchProject(entity.entityId, token!);

        if (project != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailScreen(project: project),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Không thể tải thông tin dự án';
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 24.sp),
                SizedBox(width: 8.w),
                Text('Xác nhận xóa', style: TextStyle(fontSize: 18.sp)),
              ],
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa thông báo này?\n\nHành động này không thể hoàn tác.',
              style: TextStyle(fontSize: 14.sp, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () => _deleteNotification(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _deleteNotification() {
    Navigator.pop(context); // Close dialog

    if (token != null) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      notificationProvider.deleteNotification(token!, widget.notification.id);

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa thông báo'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context); // Go back to notifications list
    }
  }
}
