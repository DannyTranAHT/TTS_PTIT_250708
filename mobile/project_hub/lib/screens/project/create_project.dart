import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  String? token;
  String? refreshToken;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _selectedStatus = 'Not Started';
  String? _selectedPriority = 'Medium';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _nameError;
  String? _startDateError;
  String? _endDateError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

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
    } catch (e) {
      print('Error initializing: $e');
    }
  }

  Future<bool> _createProject() async {
    if (token == null) {
      print('Token is null, cannot create project');
      return false;
    }
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    return await projectProvider.createProject(
      token: token!,
      name: _nameController.text,
      description: _descriptionController.text,
      status: _selectedStatus!,
      startDate: _startDate!,
      endDate: _endDate!,
      priority: _selectedPriority!,
      budget: double.tryParse(_budgetController.text) ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 240, 240),
      appBar: AppBar(
        title: Text(
          'Tạo dự án mới',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (projectProvider.errorMessage != null) {
            return Center(
              child: Text(
                projectProvider.errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
            );
          }
          return Container(
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
                      errorText: _nameError,
                      errorStyle: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12.sp,
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
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                          _startDateError = null;
                          if (_endDate != null &&
                              _endDate!.isBefore(selectedDate)) {
                            _endDate = null;
                            _endDateError = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _startDateError != null
                                  ? Colors.red[600]!
                                  : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _startDate == null
                                    ? 'Ngày bắt đầu *'
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
                          if (_startDateError != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                _startDateError!,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () async {
                      DateTime initialDate =
                          _startDate != null
                              ? _startDate!.add(Duration(days: 1))
                              : DateTime.now().add(Duration(days: 1));
                      DateTime firstDate =
                          _startDate != null
                              ? _startDate!.add(Duration(days: 1))
                              : DateTime.now().add(Duration(days: 1));
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _endDate = selectedDate;
                          _endDateError = null;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _endDateError != null
                                  ? Colors.red[600]!
                                  : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _endDate == null
                                    ? 'Ngày kết thúc *'
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
                          if (_endDateError != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                _endDateError!,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 12.sp,
                                ),
                              ),
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
                            _createProject().then((success) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Dự án đã được tạo thành công',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    backgroundColor: Colors.green[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    margin: EdgeInsets.all(16.w),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                Navigator.pop(context);
                                _nameController.clear();
                                _descriptionController.clear();
                                _budgetController.clear();
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                  _selectedStatus = 'Not Started';
                                  _selectedPriority = 'Medium';
                                  _nameError = null;
                                  _startDateError = null;
                                  _endDateError = null;
                                });
                              } else {
                                _showErrorSnackBar(
                                  projectProvider.errorMessage ??
                                      'Lỗi khi tạo dự án',
                                );
                              }
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
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _validateProject() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _startDateError = null;
      _endDateError = null;

      // Validate tên dự án
      if (_nameController.text.isEmpty) {
        _nameError = 'Tên dự án là bắt buộc';
        isValid = false;
      } else if (_nameController.text.length > 100) {
        _nameError = 'Tên dự án không được vượt quá 100 ký tự';
        isValid = false;
      }

      // Validate ngày bắt đầu
      if (_startDate == null) {
        _startDateError = 'Ngày bắt đầu là bắt buộc';
        isValid = false;
      } else {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDateOnly = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        if (startDateOnly.isBefore(today)) {
          _startDateError = 'Ngày bắt đầu phải từ hôm nay trở đi';
          isValid = false;
        }
      }

      // Validate ngày kết thúc
      if (_endDate == null) {
        _endDateError = 'Ngày kết thúc là bắt buộc';
        isValid = false;
      } else if (_startDate != null && _endDate != null) {
        if (_endDate!.isBefore(_startDate!) ||
            _endDate!.isAtSameMomentAs(_startDate!)) {
          _endDateError = 'Ngày kết thúc phải sau ngày bắt đầu';
          isValid = false;
        }
      }

      // Validate ngày kết thúc nếu không có ngày bắt đầu
      if (_startDate == null && _endDate != null) {
        _startDateError = 'Vui lòng chọn ngày bắt đầu trước';
        isValid = false;
      }

      // Validate ngân sách
      if (_budgetController.text.isNotEmpty &&
          double.tryParse(_budgetController.text) == null) {
        _showErrorSnackBar('Ngân sách phải là một số hợp lệ');
        isValid = false;
      } else if (_budgetController.text.isNotEmpty &&
          double.parse(_budgetController.text) < 0) {
        _showErrorSnackBar('Ngân sách không được là số âm');
        isValid = false;
      }
    });

    if (!isValid) {
      _showErrorSnackBar('Vui lòng điền đầy đủ và đúng các trường bắt buộc');
    }

    return isValid;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        margin: EdgeInsets.all(16.w),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
