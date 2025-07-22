import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/user_model.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _scrollController = ScrollController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();

  String _selectedRole = 'Chọn vai trò';
  bool _isSubmitted = false; // Thêm biến này để track trạng thái submit

  @override
  void initState() {
    super.initState();

    // Lắng nghe focus changes để cuộn màn hình
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        _scrollToShowField(150.h);
      }
    });

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _scrollToShowField(200.h);
      }
    });

    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _scrollToShowField(250.h);
      }
    });
  }

  void _scrollToShowField(double offset) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_isSubmitted) return null; // Chỉ validate khi đã submit

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.trim().length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Tên đăng nhập chỉ được chứa chữ, số và dấu gạch dưới';
    }
    return null;
  }

  String? _validateRole() {
    if (!_isSubmitted) return null;

    if (_selectedRole == 'Chọn vai trò') {
      return 'Vui lòng chọn vai trò';
    }
    return null;
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitted = true;
    });

    if (_formKey.currentState!.validate() && _validateRole() == null) {
      final userData = UserData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        role: _selectedRole,
      );

      Navigator.pushNamed(context, '/register2', arguments: userData);
    } else if (_validateRole() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_validateRole()!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F5F5), Color(0xFF6C63FF).withOpacity(0.1)],
            ),
          ),
          child: Column(
            children: [
              TopBar(title: 'Đăng ký', onPressed: () => Navigator.pop(context)),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.r),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: keyboardHeight > 0 ? 20.h : 0,
                        ),
                        padding: EdgeInsets.only(
                          left: 32.w,
                          right: 32.w,
                          top: 16.h,
                          bottom: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Project Hub',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            Text(
                              'Quản lý dự án thông minh',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _buildTextField(
                              'Họ và tên',
                              'Nhập họ và tên',
                              _nameController,
                              _nameFocusNode,
                              _validateName,
                              TextInputAction.next,
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_emailFocusNode),
                            ),
                            SizedBox(height: 12.h),

                            _buildTextField(
                              'Email',
                              'Nhập email',
                              _emailController,
                              _emailFocusNode,
                              _validateEmail,
                              TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_usernameFocusNode),
                            ),
                            SizedBox(height: 12.h),

                            _buildTextField(
                              'Tên đăng nhập',
                              'Tên đăng nhập là duy nhất',
                              _usernameController,
                              _usernameFocusNode,
                              _validateUsername,
                              TextInputAction.done,
                              onSubmitted:
                                  (_) => FocusScope.of(context).unfocus(),
                            ),
                            SizedBox(height: 12.h),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vai trò',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _isSubmitted &&
                                                  _validateRole() != null
                                              ? Colors.red
                                              : Color(0xFFE9ECEF),
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedRole,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 10.h,
                                      ),
                                    ),
                                    items:
                                        [
                                          'Chọn vai trò',
                                          'Project Manager',
                                          'Developer',
                                          'Designer',
                                          'Tester',
                                          'Business Analyst',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color:
                                                    value == 'Chọn vai trò'
                                                        ? Colors.grey[500]
                                                        : Colors.black,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedRole = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 25.h),

                            Container(
                              width: double.infinity,
                              height: 56.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF8B5FBF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: _continue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Tiếp tục',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                            Text(
                              'hoặc',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đã có tài khoản? ',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14.sp,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Text(
                                    'Đăng nhập ngay',
                                    style: TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: keyboardHeight > 0 ? 100.h : 0),
                          ],
                        ),
                      ),
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    FocusNode focusNode,
    String? Function(String?) validator,
    TextInputAction textInputAction, {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            onFieldSubmitted: onSubmitted,
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 5.h,
              ),
              errorStyle: TextStyle(fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }
}
