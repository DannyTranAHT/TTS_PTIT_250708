import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/screens/home/home.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/top_bar_auth.dart';

class RegisterScreen2 extends StatefulWidget {
  const RegisterScreen2({super.key});

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
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

  String? _validateMajor(String? value) {
    if (!_isSubmitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập chuyên ngành';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isSubmitted = true;
    });

    if (!_formKey.currentState!.validate() || userData == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      username: userData!.username,
      email: userData!.email,
      fullName: userData!.fullName,
      password: _passwordController.text,
      role: userData!.role,
      major:
          _majorController.text.trim().isNotEmpty
              ? _majorController.text.trim()
              : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    TopBarAuth(
                      title: 'Hoàn tất đăng ký',
                      isBack: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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

                              // User Info Summary
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFE9ECEF),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin tài khoản:',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Tên: ${userData!.fullName}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Email: ${userData!.email}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Vai trò: ${userData!.role}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Password Field
                              _buildTextField(
                                'Mật khẩu',
                                'Nhập mật khẩu mới',
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
                                    (_) =>
                                        _confirmPasswordFocusNode
                                            .requestFocus(),
                              ),

                              SizedBox(height: 20.h),

                              // Confirm Password Field
                              _buildTextField(
                                'Xác nhận mật khẩu',
                                'Nhập lại mật khẩu',
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
                                    (_) => _majorFocusNode.requestFocus(),
                              ),

                              SizedBox(height: 20.h),

                              // Major Field
                              _buildTextField(
                                'Chuyên ngành',
                                'VD: Công nghệ thông tin',
                                _majorController,
                                _majorFocusNode,
                                _validateMajor,
                                TextInputAction.done,
                                onSubmitted: (_) => _handleRegister(),
                              ),

                              SizedBox(height: 40.h),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed:
                                      authProvider.isLoading
                                          ? null
                                          : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child:
                                      authProvider.isLoading
                                          ? SizedBox(
                                            width: 24.w,
                                            height: 24.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                          )
                                          : Text(
                                            'Hoàn tất đăng ký',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    userData!.role == 'Employee' ? 50.h : 100.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
            color: const Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          textInputAction: textInputAction,
          obscureText: isPassword && obscureText,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D2D2D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
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
      ],
    );
  }
}
