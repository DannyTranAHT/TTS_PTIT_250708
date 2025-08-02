import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/user_model.dart';
import 'package:project_hub/screens/widgets/top_bar_auth.dart';

class RegisterScreen2 extends StatefulWidget {
  @override
  _RegisterScreen2State createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _majorController = TextEditingController();
  final _scrollController = ScrollController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _majorFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitted = false;

  User? userData;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _scrollToShowField(200.h);
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        _scrollToShowField(280.h);
      }
    });

    _majorFocusNode.addListener(() {
      if (_majorFocusNode.hasFocus) {
        _scrollToShowField(360.h);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userData == null) {
      userData = ModalRoute.of(context)?.settings.arguments as User?;
    }
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _majorController.dispose();
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _majorFocusNode.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường và 1 số';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  void _register() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitted = true;
    });

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
              TopBarAuth(
                title: 'Đăng ký',
                onPressed: () => Navigator.pop(context),
                isBack: true,
              ),

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
                      padding: EdgeInsets.all(18.r),
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
                                fontSize: 28.sp,
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

                            SizedBox(height: 30.h),

                            _buildTextField(
                              'Mật khẩu',
                              'Nhập mật khẩu',
                              _passwordController,
                              _passwordFocusNode,
                              _validatePassword,
                              TextInputAction.next,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_confirmPasswordFocusNode),
                            ),
                            SizedBox(height: 16.h),

                            _buildTextField(
                              'Xác nhận mật khẩu',
                              'Xác nhận mật khẩu',
                              _confirmPasswordController,
                              _confirmPasswordFocusNode,
                              _validateConfirmPassword,
                              TextInputAction.next,
                              isPassword: true,
                              obscureText: _obscureConfirmPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_majorFocusNode),
                            ),
                            SizedBox(height: 16.h),

                            _buildTextField(
                              'Chuyên ngành của bạn',
                              'Không bắt buộc',
                              _majorController,
                              _majorFocusNode,
                              null,
                              TextInputAction.done,
                              onSubmitted:
                                  (_) => FocusScope.of(context).unfocus(),
                            ),

                            SizedBox(height: 48.h),

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
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Đăng ký',
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
    String? Function(String?)? validator,
    TextInputAction textInputAction, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
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
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          padding: EdgeInsets.only(top: 16.h),
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
            obscureText: isPassword && obscureText,
            onFieldSubmitted: onSubmitted,
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              errorStyle: TextStyle(fontSize: 12.sp),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                          size: 24.sp,
                        ),
                        onPressed: onToggleObscure,
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
