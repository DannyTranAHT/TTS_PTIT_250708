import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:provider/provider.dart';

class ProjectSettingsDialog extends StatelessWidget {
  final Project project;
  final String token;

  const ProjectSettingsDialog({
    Key? key,
    required this.project,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt dự án',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Project Option
              _buildSettingOption(
                context,
                icon: Icons.edit,
                title: 'Chỉnh sửa dự án',
                subtitle: 'Thay đổi thông tin dự án',
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditProjectDialog(context);
                },
              ),

              SizedBox(height: 16.h),

              // Delete Project Option
              _buildSettingOption(
                context,
                icon: Icons.delete,
                title: 'Xóa dự án',
                subtitle: 'Xóa dự án vĩnh viễn',
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(context);
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isDestructive
                    ? Colors.red.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isDestructive ? Colors.red : Color(0xFF667EEA),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProjectDialog(project: project, token: token),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteProjectDialog(project: project, token: token),
    );
  }
}

class EditProjectDialog extends StatefulWidget {
  final Project project;
  final String token;

  const EditProjectDialog({
    Key? key,
    required this.project,
    required this.token,
  }) : super(key: key);

  @override
  _EditProjectDialogState createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedStatus = 'In Progress';
  String _selectedPriority = 'Medium';
  late TextEditingController _budgetController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );
    _selectedStatus = widget.project.status;
    _selectedPriority = widget.project.priority;
    _budgetController = TextEditingController(
      text: widget.project.budget.toString(),
    );
    _startDate = widget.project.startDate;
    _endDate = widget.project.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _startDate = null;
    _endDate = null;
    _selectedStatus = 'In Progress';
    _selectedPriority = 'Medium';

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chỉnh sửa dự án',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Project Name
              Text(
                'Tên dự án',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên dự án',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFF667EEA)),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Project Description
              Text(
                'Mô tả dự án',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập mô tả dự án',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFF667EEA)),
                  ),
                ),
              ),

              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items:
                    [
                          'Not Started',
                          'In Progress',
                          'Completed',
                          'On Hold',
                          'Cancelled',
                        ]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
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
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Ngân sách',
                  hintText: 'Nhập ngân sách (không bắt buộc)',
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
              SizedBox(height: 36.h),

              // Start Date
              Text(
                'Ngày bắt đầu',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Chọn ngày bắt đầu',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color:
                              _startDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: Color(0xFF667EEA),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // End Date
              Text(
                'Ngày kết thúc',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Chọn ngày kết thúc',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color:
                              _endDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: Color(0xFF667EEA),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667EEA),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Lưu',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _updateProject() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập tên dự án')));
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập mô tả dự án')));
      return;
    }
    if (_budgetController.text.isNotEmpty &&
        double.tryParse(_budgetController.text) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập ngân sách hợp lệ')));
      return;
    }

    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    Map<String, dynamic> updatedData = {};
    if (_nameController.text != widget.project.name) {
      updatedData['name'] = _nameController.text;
    }
    if (_descriptionController.text != widget.project.description) {
      updatedData['description'] = _descriptionController.text;
    }
    if (_selectedStatus != widget.project.status) {
      updatedData['status'] = _selectedStatus;
    }
    if (_selectedPriority != widget.project.priority) {
      updatedData['priority'] = _selectedPriority;
    }
    if (_startDate != null && _startDate != widget.project.startDate) {
      updatedData['start_date'] = _startDate!.toIso8601String();
    }
    if (_endDate != null && _endDate != widget.project.endDate) {
      updatedData['end_date'] = _endDate!.toIso8601String();
    }
    if (_budgetController.text.isNotEmpty &&
        double.tryParse(_budgetController.text) != null &&
        double.parse(_budgetController.text) != widget.project.budget) {
      updatedData['budget'] = double.parse(_budgetController.text);
    }

    print('Updated Data: $updatedData');
    if (updatedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có thay đổi nào để cập nhật')),
      );
      return;
    }
    await projectProvider
        .updateProject(
          id: widget.project.id!,
          token: widget.token,
          data: updatedData,
        )
        .then((success) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật dự án thành công')),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  projectProvider.errorMessage ?? 'Cập nhật dự án thất bại',
                ),
              ),
            );
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $error')));
        });
  }
}

class DeleteProjectDialog extends StatefulWidget {
  final Project project;
  final String token;

  const DeleteProjectDialog({
    Key? key,
    required this.project,
    required this.token,
  }) : super(key: key);

  @override
  _DeleteProjectDialogState createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, size: 32.sp, color: Colors.red),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              'Xóa dự án',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              'Bạn có chắc chắn muốn xóa dự án "${widget.project.name}"?\n\nHành động này không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _deleteProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Xóa',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );

      final success = await projectProvider.deleteProject(
        widget.project.id!,
        widget.token,
      );

      if (success) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa dự án thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(projectProvider.errorMessage ?? 'Xóa dự án thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
