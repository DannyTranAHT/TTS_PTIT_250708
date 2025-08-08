import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:project_hub/config/status_config.dart';
import 'package:project_hub/models/comment_model.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/models/task_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/providers/task_provider.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final bool isManager;
  const TaskDetailScreen({
    super.key,
    required this.task,
    this.isManager = false,
  });
  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String? token;
  String? refreshToken;
  final TextEditingController _commentController = TextEditingController();

  List<Comment> comments = [
    Comment(
      author: 'Jane Smith',
      content: 'Mockup trông rất tốt! Tuy nhiên mình nghĩ nên',
      time: '',
      avatar: 'JS',
    ),
    Comment(
      author: 'John Doe',
      content: 'Đồng ý với Jane. Và có thể thêm dark mode to',
      time: '',
      avatar: 'JD',
    ),
    Comment(
      author: 'Nguyễn Văn A',
      content: 'Cám ơn feedback! Mình sẽ update design với c cuối tuần.',
      time: '',
      avatar: 'NA',
    ),
  ];
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final loadedToken = await StorageService.getToken();
      final loadedRefreshToken = await StorageService.getRefreshToken();

      setState(() {
        token = loadedToken;
        refreshToken = loadedRefreshToken;
      });

      if (token != null && mounted) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.fetchTaskById(
          token: token!,
          taskId: widget.task.id!,
        );
      }
    } catch (e) {
      print('Error initializing: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _assignedToMember(String memberId) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider
          .assignTaskToMember(
            token: token!,
            taskId: widget.task.id!,
            memberId: memberId,
          )
          .then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Giao công việc thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Giao công việc thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi giao công việc: $e')));
    }
  }

  Future<void> unAssignedToMember(String memberId) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider
          .unAssignTaskToMember(
            token: token!,
            taskId: widget.task.id!,
            memberId: memberId,
          )
          .then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hủy giao công việc thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hủy giao công việc thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi hủy giao công việc: $e')));
    }
  }

  Future<void> requestCompleted() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider
          .requestTaskCompleted(token: token!, taskId: widget.task.id!)
          .then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Yêu cầu hoàn thành công việc đã được gửi'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Yêu cầu hoàn thành công việc thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi yêu cầu hoàn thành công việc: $e')),
      );
    }
  }

  Future<void> comfirmCompleted(bool confirm) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider
          .confirmTaskCompleted(
            token: token!,
            taskId: widget.task.id!,
            confirm: confirm,
          )
          .then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    confirm
                        ? 'Công việc đã được xác nhận hoàn thành'
                        : 'Công việc đã được xác nhận chưa hoàn thành',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xác nhận công việc thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xác nhận công việc: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              TopBar(isBack: true),
              // Content
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    if (taskProvider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (taskProvider.errorMessage != null) {
                      return Center(
                        child: Text(
                          'Lỗi: ${taskProvider.errorMessage}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    Task? task = taskProvider.selectedTask;
                    if (task == null) {
                      return Center(
                        child: Text(
                          'Không tìm thấy thông tin công việc.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 2.r),
                        ),
                      ),

                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.name,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                task.status == 'Done'
                                    ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 30.sp,
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Task Info
                            _buildTaskInfoSection(task),

                            SizedBox(height: 20.h),

                            // Description
                            _buildDescriptionSection(task),

                            SizedBox(height: 20.h),

                            // Attachments
                            _buildAttachmentsSection(task),

                            SizedBox(height: 20.h),
                            // Confirm Button
                            _buildComfirm(task),
                            SizedBox(height: 20.h),

                            // Comments
                            _buildCommentsSection(task),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoSection(Task task) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRẠNG THÁI',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      StatusConfig.changTaskStatus(task.status),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: StatusConfig.taskStatusColor(task.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ĐỘ ƯU TIÊN',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HẠN HOÀN THÀNH',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      task.dueDate != null
                          ? DateFormat('dd/MM/yyyy').format(task.dueDate!)
                          : 'Không có hạn',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NGÀY BẮT ĐẦU',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      task.createdAt != null
                          ? DateFormat('dd/MM/yyyy').format(task.createdAt!)
                          : 'Không có ngày bắt đầu',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          task.assignedTo != null
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Color(0xFF6C63FF),
                        child: Text(
                          task.assignedTo!.fullName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        task.assignedTo!.fullName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  widget.isManager
                      ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) =>
                                    _buildRemoveMember(task.assignedTo!.id),
                          );
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Color.fromARGB(255, 255, 6, 6),
                          size: 26.sp,
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Chưa có người được giao',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  widget.isManager
                      ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildAddMember(),
                          );
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF6C63FF),
                          size: 26.sp,
                        ),
                      )
                      : SizedBox.shrink(),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          task.description.isNotEmpty ? task.description : 'Không có mô tả',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tệp đính kèm',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 12.h),
        // Mockup files
        (task.attachments != null && task.attachments != "")
            ? Row(
              children: [
                Icon(Icons.attach_file, color: Color(0xFF6C63FF), size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'dashboard_design_v1.png',
                    style: TextStyle(fontSize: 14.sp, color: Color(0xFF2D2D2D)),
                  ),
                ),
              ],
            )
            : Text(
              'Không có tệp đính kèm',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
      ],
    );
  }

  Widget _buildComfirm(Task task) {
    return (widget.isManager && task.status != "In Review")
        ? SizedBox.shrink()
        : (widget.isManager && task.status == "In Review")
        ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Xác nhận chưa hoàn thành công việc',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        content: Text(
                          'Bạn có chắc chắn muốn xác nhận công việc này chưa hoàn thành?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              comfirmCompleted(false);
                            },
                            child: Text('Xác nhận'),
                          ),
                        ],
                      ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.r),
                height: 60.h,
                width: 160.w,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.r),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Blocked',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Xác nhận hoàn thành công việc',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        content: Text(
                          'Bạn có chắc chắn muốn xác nhận công việc này đã hoàn thành?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              comfirmCompleted(true);
                            },
                            child: Text('Xác nhận'),
                          ),
                        ],
                      ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.r),
                height: 60.h,
                width: 160.w,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.r),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
        : InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      'Hoàn thành công việc',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    content: Text(
                      'Bạn có chắc chắn đã hoàn thành công việc này?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (task.status == "In Review") {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Công việc đang trong trạng thái xem xét.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          requestCompleted();
                        },
                        child: Text('Xác nhận'),
                      ),
                    ],
                  ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.r),
            height: 60.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.r),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Hoàn thành công việc',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildCommentsSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bình luận',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 12.h),

        // Comment input
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.sp,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),

              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Gửi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Comments list
        ...comments.map((comment) => _buildCommentItem(comment)),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Color(0xFF6C63FF),
            child: Text(
              comment.avatar,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMember() {
    Project? project = Provider.of<ProjectProvider>(context).selectedProject;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn thành viên thực hiện',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (project != null && project.members!.isNotEmpty)
              Column(
                children:
                    project.members!.map((member) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.r),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Color(0xFF6C63FF),
                            child: Text(
                              member.fullName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(member.fullName),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Xác nhận giao công việc',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: Text(
                                    'Bạn có chắc chắn muốn giao công việc này cho ${member.fullName}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _assignedToMember(member.id!);
                                      },
                                      child: Text('Xác nhận'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    }).toList(),
              )
            else
              Text('Không có thành viên nào trong dự án này'),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveMember(String memberId) {
    return AlertDialog(
      title: Text(
        'Xác nhận hủy giao công việc',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D2D2D),
        ),
      ),
      content: Text(
        'Bạn có chắc chắn muốn hủy giao công việc này cho người dùng này?',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
        TextButton(
          onPressed: () {
            unAssignedToMember(memberId);
          },
          child: Text('Xác nhận'),
        ),
      ],
    );
  }
}
