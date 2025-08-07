import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/config/status_config.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/models/task_model.dart';
import 'package:project_hub/providers/task_provider.dart';
import 'package:project_hub/screens/task/task_detail.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatefulWidget {
  final Project project;
  final bool isManager;
  const TaskListScreen({
    Key? key,
    required this.project,
    this.isManager = false,
  }) : super(key: key);
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> tasks = [];
  String? token;
  String? refreshToken;

  // Controllers cho dialog tạo task
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  String? _selectedMember = 'None';
  String? _selectedPriority = 'Medium';
  DateTime? _dueDate;

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
        await taskProvider.fetchAllOfProject(token!, widget.project.id ?? '');
        setState(() {
          tasks.addAll(taskProvider.tasks);
        });
      }
    } catch (e) {
      print('Error initializing: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Top Bar
                TopBar(isBack: true),

                // Project Info Section
                Container(
                  padding: EdgeInsets.all(16.r),
                  child: Container(
                    height: 80.h,
                    child: Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.web,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 8.h),
                            height: 80.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 18.sp,
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
                                    color: StatusConfig.statusColor(
                                      widget.project.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    StatusConfig.changeStatus(
                                      widget.project.status,
                                    ).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: StatusConfig.statusColor(
                                        widget.project.status,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Task List Section
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 16.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border(
                        top: BorderSide(color: Color(0xFF667EEA), width: 5.w),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Danh sách task',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              widget.isManager
                                  ? GestureDetector(
                                    onTap: _showCreateTaskDialog,
                                    child: Container(
                                      height: 32.h,
                                      width: 86.w,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF6C63FF),
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Thêm',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),

                        // Task List - Sử dụng Expanded để chiếm không gian còn lại
                        Expanded(
                          child: Consumer<TaskProvider>(
                            builder: (context, value, child) {
                              if (value.isLoading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (value.errorMessage != null) {
                                return Center(
                                  child: Text(
                                    value.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                );
                              }
                              if (value.tasks.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Không có task nào',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }
                              final tasks = value.tasks;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                child: ListView.separated(
                                  padding: EdgeInsets.only(
                                    bottom: 16.h,
                                  ), // Thêm padding bottom
                                  itemCount: tasks.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          SizedBox(height: 12.h),
                                  itemBuilder: (context, index) {
                                    return _buildTaskCard(tasks[index]);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Sử dụng StatefulBuilder để setState trong dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'Tạo task mới',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF2D2D2D),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tên task *',
                          hintText: 'Nhập tên task (tối đa 200 ký tự)',
                          labelStyle: TextStyle(fontSize: 14.sp),

                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        maxLength: 200,
                      ),
                      SizedBox(height: 5.h),
                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF2D2D2D),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          hintText: 'Nhập mô tả task (không bắt buộc)',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setStateDialog(() {
                              _dueDate = selectedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate == null
                                    ? 'Ngày hết hạn *'
                                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      _dueDate == null
                                          ? Colors.grey[600]
                                          : Color(0xFF2D2D2D),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF2D2D2D),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Độ ưu tiên',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        items:
                            ['Low', 'Medium', 'High', 'Critical']
                                .map(
                                  (priority) => DropdownMenuItem(
                                    value: priority,
                                    child: Text(
                                      priority,
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            _selectedPriority = value;
                          });
                        },
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: _selectedMember,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF2D2D2D),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Người thực hiện',
                          hintText: 'Chọn người thực hiện',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        items:
                            [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Flexible(
                                  child: Text(
                                    'Chọn người thực hiện',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                    overflow:
                                        TextOverflow
                                            .ellipsis, // Cắt bớt văn bản nếu quá dài
                                  ),
                                ),
                              ),
                              ...[
                                'None',
                                'Nguyễn Văn A',
                                'Trần Thị B',
                                'Lê Văn C',
                              ].map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Flexible(
                                    child: Text(
                                      status,
                                      style: TextStyle(fontSize: 14.sp),
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Cắt bớt văn bản nếu quá dài
                                    ),
                                  ),
                                ),
                              ),
                            ].toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            _selectedMember = value;
                          });
                        },
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _hoursController,
                        decoration: InputDecoration(
                          labelText: 'Số giờ làm việc',
                          hintText: 'Nhập số giờ (không bắt buộc)',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Hủy',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_validateTask()) {
                      final taskData = {
                        'project_id': 'mock_project_id',
                        'name': _nameController.text,
                        'description':
                            _descriptionController.text.isEmpty
                                ? null
                                : _descriptionController.text,
                        'due_date': _dueDate?.toIso8601String(),
                        'status': 'To Do',
                        'priority': _selectedPriority,
                        'assigned_to_id': _selectedMember,
                        'hours': int.tryParse(_hoursController.text) ?? 0,
                        'attachments': [],
                      };
                      print('Dữ liệu task: $taskData');
                      Navigator.pop(context);
                      // Reset form
                      _resetForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Tạo',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _hoursController.clear();
    setState(() {
      _dueDate = null;
      _selectedPriority = 'Medium';
      _selectedMember = 'None';
    });
  }

  bool _validateTask() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tên task là bắt buộc')));
      return false;
    }
    if (_nameController.text.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tên task không được vượt quá 200 ký tự')),
      );
      return false;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ngày hết hạn là bắt buộc')));
      return false;
    }
    if (_dueDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ngày hết hạn phải lớn hơn ngày hiện tại')),
      );
      return false;
    }
    if (_selectedMember == 'None') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Người thực hiện là bắt buộc')));
      return false;
    }
    if (_hoursController.text.isNotEmpty &&
        int.tryParse(_hoursController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số giờ làm việc phải là một số hợp lệ')),
      );
      return false;
    }
    if (_hoursController.text.isNotEmpty &&
        int.parse(_hoursController.text) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số giờ làm việc không được là số âm')),
      );
      return false;
    }
    return true;
  }

  Widget _buildTaskCard(Task task) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    TaskDetailScreen(task: task, isManager: widget.isManager),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            bottom: BorderSide(color: Color(0xFF667EEA), width: 2.w),
            right: BorderSide(color: Color(0xFF667EEA), width: 0.5.w),
            top: BorderSide(color: Color(0xFF667EEA), width: 0.2.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                  child: Text(
                    'Xem',
                    style: TextStyle(
                      color: Color(0xFF6397FF),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            _buildTaskInfo(
              task.assignedTo != null
                  ? 'Người thực hiện: ${task.assignedTo?.fullName}'
                  : 'Chưa có người thực hiện',
              Colors.black,
            ),
            _buildTaskInfo('Tình trạng: ${task.status}', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo(String text, Color color) {
    return Container(
      width: double.infinity,
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: color),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
