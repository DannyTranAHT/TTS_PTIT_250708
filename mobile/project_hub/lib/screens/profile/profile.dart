import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/screens/widgets/avatar_card.dart';
import 'package:project_hub/screens/widgets/bottom_bar.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');
  final _emailController = TextEditingController(
    text: 'nguyenvana@example.com',
  );
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Employee';
  String _selectedMajor = 'BE Dev';

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(isBack: false),
              ),
              // Thẻ thông tin cá nhân
              Positioned(
                top: 80.h,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tiêu đề
                        Container(
                          height: 36.h,
                          width: double.infinity,
                          child: Text(
                            'Thông tin cá nhân',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667EEA),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        // Ảnh đại diện và nút thay đổi
                        AvatarCard(),
                        SizedBox(height: 32.h),

                        _buildTextField('HỌ VÀ TÊN', _nameController),
                        SizedBox(height: 16.h),

                        _buildTextField('EMAIL', _emailController),
                        SizedBox(height: 16.h),

                        _buildDropdownField(
                          'VAI TRÒ',
                          _selectedRole,
                          ['Employee', 'Manager', 'Admin'],
                          (value) => setState(() => _selectedRole = value!),
                        ),
                        SizedBox(height: 16.h),

                        _buildDropdownField(
                          'CHUYÊN NGÀNH',
                          _selectedMajor,
                          ['BE Dev', 'FE Dev', 'Full Stack', 'UI/UX', 'QA'],
                          (value) => setState(() => _selectedMajor = value!),
                        ),

                        SizedBox(height: 24.h),

                        // Nút Lưu Thông Tin
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF8B5FBF)],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cập nhật thông tin thành công!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Thay đổi mật khẩu
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Color(0xFFE9ECEF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thay đổi mật khẩu',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              _buildPasswordField(
                                'NHẬP MẬT KHẨU CŨ',
                                _oldPasswordController,
                                _obscureOldPassword,
                                () => setState(
                                  () =>
                                      _obscureOldPassword =
                                          !_obscureOldPassword,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              _buildPasswordField(
                                'NHẬP MẬT KHẨU MỚI',
                                _newPasswordController,
                                _obscureNewPassword,
                                () => setState(
                                  () =>
                                      _obscureNewPassword =
                                          !_obscureNewPassword,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              _buildPasswordField(
                                'XÁC NHẬN MẬT KHẨU MỚI',
                                _confirmPasswordController,
                                _obscureConfirmPassword,
                                () => setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              Container(
                                width: double.infinity,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF8B5FBF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đổi mật khẩu thành công!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Lưu thay đổi',
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
                        ),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomBar(index: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 16.sp, color: Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(fontSize: 16.sp, color: Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
