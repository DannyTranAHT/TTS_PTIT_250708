import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/screens/auth/register2.dart';
import '../../models/user_model.dart';
import '../widgets/top_bar_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _scrollController = ScrollController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _fullNameFocusNode = FocusNode();

  String _selectedRole = 'Employee';
  bool _isSubmitted = false;

  final List<String> _roles = ['Employee', 'Project Manager', 'Admin'];

  @override
  void initState() {
    super.initState();

    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _scrollToShowField(200.h);
      }
    });

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _scrollToShowField(280.h);
      }
    });

    _fullNameFocusNode.addListener(() {
      if (_fullNameFocusNode.hasFocus) {
        _scrollToShowField(360.h);
      }
    });
  }

  void _scrollToShowField(double offset) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _scrollController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _fullNameFocusNode.dispose();
    super.dispose();
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
      return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  void _handleNext() {
    setState(() {
      _isSubmitted = true;
    });

    if (_formKey.currentState!.validate()) {
      final userData = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _selectedRole,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterScreen2(),
          settings: RouteSettings(arguments: userData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            TopBarAuth(title: 'Đăng ký', isBack: false, onPressed: () {}),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 200.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),

                      // Username Field
                      _buildTextField(
                        'Tên đăng nhập',
                        'Nhập tên đăng nhập của bạn',
                        _usernameController,
                        _usernameFocusNode,
                        _validateUsername,
                        TextInputAction.next,
                        onSubmitted: (_) => _emailFocusNode.requestFocus(),
                      ),

                      SizedBox(height: 20.h),

                      // Email Field
                      _buildTextField(
                        'Email',
                        'Nhập email của bạn',
                        _emailController,
                        _emailFocusNode,
                        _validateEmail,
                        TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _fullNameFocusNode.requestFocus(),
                      ),

                      SizedBox(height: 20.h),

                      // Full Name Field
                      _buildTextField(
                        'Họ và tên',
                        'Nhập họ và tên đầy đủ',
                        _fullNameController,
                        _fullNameFocusNode,
                        _validateFullName,
                        TextInputAction.done,
                        onSubmitted: (_) => _handleNext(),
                      ),

                      SizedBox(height: 20.h),

                      // Role Selection
                      Text(
                        'Vai trò',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF2D2D2D),
                            ),
                            items:
                                _roles.map((String role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue!;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Đã có tài khoản? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Đăng nhập ngay',
                                  style: TextStyle(
                                    color: const Color(0xFF6C63FF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    FocusNode focusNode,
    String? Function(String?)? validator,
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
            color: const Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D2D2D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }
}
