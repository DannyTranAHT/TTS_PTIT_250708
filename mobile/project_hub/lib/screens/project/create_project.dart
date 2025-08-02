import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _membersController = TextEditingController();
  String? _selectedStatus = 'Not Started';
  String? _selectedPriority = 'Medium';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo dự án mới',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên dự án *',
                  hintText: 'Nhập tên dự án (tối đa 100 ký tự)',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                maxLength: 100,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả dự án (không bắt buộc)',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                maxLines: 3,
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
                    setState(() {
                      _startDate = selectedDate;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate == null
                            ? 'Ngày bắt đầu'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color:
                              _startDate == null
                                  ? Colors.grey[500]
                                  : Color(0xFF2D2D2D),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
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
                    setState(() {
                      _endDate = selectedDate;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate == null
                            ? 'Ngày kết thúc'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color:
                              _endDate == null
                                  ? Colors.grey[500]
                                  : Color(0xFF2D2D2D),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: Colors.grey[500],
                      ),
                    ],
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
                    _selectedStatus = value;
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
                    _selectedPriority = value;
                  });
                },
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _membersController,
                decoration: InputDecoration(
                  labelText: 'Thành viên (ID, cách nhau bởi dấu phẩy)',
                  hintText: 'Ví dụ: user1, user2, user3',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
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
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_validateProject()) {
                        final projectData = {
                          'name': _nameController.text,
                          'description': _descriptionController.text,
                          'start_date': _startDate?.toIso8601String(),
                          'end_date': _endDate?.toIso8601String(),
                          'status': _selectedStatus,
                          'priority': _selectedPriority,
                          'members':
                              _membersController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList(),
                          'budget':
                              double.tryParse(_budgetController.text) ?? 0,
                        };
                        print('Dữ liệu dự án: $projectData');
                        Navigator.pop(context);
                        _nameController.clear();
                        _descriptionController.clear();
                        _budgetController.clear();
                        _membersController.clear();
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _selectedStatus = 'Not Started';
                          _selectedPriority = 'Medium';
                        });
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateProject() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tên dự án là bắt buộc')));
      return false;
    }
    if (_nameController.text.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tên dự án không được vượt quá 100 ký tự')),
      );
      return false;
    }
    if (_budgetController.text.isNotEmpty &&
        double.tryParse(_budgetController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ngân sách phải là một số hợp lệ')),
      );
      return false;
    }
    if (_budgetController.text.isNotEmpty &&
        double.parse(_budgetController.text) < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ngân sách không được là số âm')));
      return false;
    }
    return true;
  }
}
