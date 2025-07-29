import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/comment_model.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';

class TaskDetailScreen extends StatefulWidget {
  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  List<ChecklistItem> checklistItems = [
    ChecklistItem(
      title: 'Phân tích requirements và wireframe',
      isCompleted: true,
    ),
    ChecklistItem(title: 'Thiết kế mockup cho Light mode', isCompleted: true),
    ChecklistItem(title: 'Thiết kế mockup cho Dark mode', isCompleted: false),
    ChecklistItem(title: 'Tạo prototype tương tác', isCompleted: false),
    ChecklistItem(title: 'Review với team và stakeholders', isCompleted: false),
    ChecklistItem(title: 'Handoff cho developers', isCompleted: false),
  ];

  List<FileItem> attachments = [
    FileItem(name: 'Dashboard_Mockup_v1.fig', size: '2.5 MB'),
    FileItem(name: 'Design_System_Guide.pdf', size: '1.2 MB'),
    FileItem(name: 'User_Flow_Diagram.jpg', size: '850 KB'),
  ];

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

              // Project Info
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 2.r,
                          ),
                        ),
                      ),
                      child: Icon(Icons.web, color: Colors.white, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mobile App Development',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            height: 28.h,
                            width: 136.w,
                            padding: EdgeInsets.only(top: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'ĐANG THỰC HIỆN',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
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
                                'Thiết kế UI',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30.sp,
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Task Info
                        _buildTaskInfoSection(),

                        SizedBox(height: 20.h),

                        // Description
                        _buildDescriptionSection(),

                        SizedBox(height: 20.h),

                        // Checklist
                        _buildChecklistSection(),

                        SizedBox(height: 20.h),

                        // Attachments
                        _buildAttachmentsSection(),

                        SizedBox(height: 20.h),

                        // Comments
                        _buildCommentsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoSection() {
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
                      'ĐANG THỰC HIỆN',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue,
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
                      'CAO',
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
                      '16/10/2023',
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
                      '01/10/2023',
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
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Color(0xFF6C63FF),
                child: Text(
                  'NA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Nguyễn Văn A',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
          'Thiết kế giao diện dashboard cho ứng dụng mobile với các tính năng:\n\n• Tổng quan doanh số và metrics quan trọng\n• Biểu đồ thống kê tương tác\n• Responsive design cho nhiều kích thước màn hình\n• Dark mode support\n• Animation và micro-interactions',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 12.h),
        ...checklistItems.map((item) => _buildChecklistItem(item)),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: item.isCompleted ? Color(0xFF6C63FF) : Colors.transparent,
              border: Border.all(
                color: item.isCompleted ? Color(0xFF6C63FF) : Colors.grey[400]!,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child:
                item.isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                    : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 14.sp,
                color: item.isCompleted ? Colors.grey[600] : Color(0xFF2D2D2D),
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
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
        ...attachments.map((file) => _buildAttachmentItem(file)),
      ],
    );
  }

  Widget _buildAttachmentItem(FileItem file) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Colors.grey[600], size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  file.size,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
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
              TextButton(
                onPressed: () {
                  // Add comment logic
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
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
                  'Gửi bình luận',
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
}

class ChecklistItem {
  final String title;
  final bool isCompleted;

  ChecklistItem({required this.title, required this.isCompleted});
}

class FileItem {
  final String name;
  final String size;

  FileItem({required this.name, required this.size});
}
