import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:project_hub/providers/auth_provider.dart';
import 'package:project_hub/screens/widgets/avatar_card.dart';
import 'package:project_hub/screens/widgets/bottom_bar.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Employee';
  String _selectedMajor = 'Other';

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;

  List<String> _majors = [
    'BE Dev',
    'FE Dev',
    'Full Stack',
    'UI/UX',
    'QA',
    'DevOps',
    'Data Science',
    'Mobile Dev',
    'Business Management',
    'Project Management',
    'Marketing',
    'Sales',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  // Ensure major is valid
  String _validateMajor(String? major) {
    if (major == null || major.isEmpty || !_majors.contains(major)) {
      return 'BE Dev'; // Default value
    }
    return major;
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _selectedRole = user.role;
        _selectedMajor = _validateMajor(user.major);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Update profile info
  Future<void> _updateProfile() async {
    setState(() {
      _isUpdatingProfile = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('Updating profile with major: $_selectedMajor');

    final success = await authProvider.updateProfile(
      fullName: _nameController.text.trim(),
      major: _selectedMajor,
    );

    if (success) {
      _showSnackBar('Cập nhật thông tin thành công!');
    } else {
      _showSnackBar(
        'Lỗi cập nhật: ${authProvider.errorMessage}',
        isError: true,
      );
    }

    setState(() {
      _isUpdatingProfile = false;
    });
  }

  // Change password
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Mật khẩu xác nhận không khớp!', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự!', isError: true);
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.changePassword(
      currentPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (success) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSnackBar('Đổi mật khẩu thành công!');
    } else {
      _showSnackBar(
        'Lỗi đổi mật khẩu: ${authProvider.errorMessage}',
        isError: true,
      );
    }

    setState(() {
      _isChangingPassword = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

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

                        _buildTextField(
                          'EMAIL',
                          _emailController,
                          readOnly: true,
                        ),
                        SizedBox(height: 16.h),

                        _buildDropdownField(
                          'VAI TRÒ',
                          _selectedRole,
                          ['Employee', 'Project Manager', 'Admin'],
                          null,
                          readOnly: true,
                        ),
                        SizedBox(height: 16.h),

                        _buildDropdownField(
                          'CHUYÊN NGÀNH',
                          _validateMajor(_selectedMajor),
                          _majors,
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
                            onPressed:
                                _isUpdatingProfile ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child:
                                _isUpdatingProfile
                                    ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
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
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              _buildPasswordField(
                                'MẬT KHẨU HIỆN TẠI',
                                _oldPasswordController,
                                _obscureOldPassword,
                                () => setState(
                                  () =>
                                      _obscureOldPassword =
                                          !_obscureOldPassword,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              _buildPasswordField(
                                'MẬT KHẨU MỚI',
                                _newPasswordController,
                                _obscureNewPassword,
                                () => setState(
                                  () =>
                                      _obscureNewPassword =
                                          !_obscureNewPassword,
                                ),
                              ),
                              SizedBox(height: 16.h),

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
                              SizedBox(height: 20.h),

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
                                  onPressed:
                                      _isChangingPassword
                                          ? null
                                          : _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child:
                                      _isChangingPassword
                                          ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : Text(
                                            'Đổi mật khẩu',
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
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
            color: readOnly ? Color(0xFFF5F5F5) : Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: 16.sp,
              color: readOnly ? Colors.grey[600] : Color(0xFF2D2D2D),
            ),
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
    Function(String?)? onChanged, {
    bool readOnly = false,
  }) {
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
            color: readOnly ? Color(0xFFF5F5F5) : Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child:
              readOnly
                  ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                  : DropdownButtonFormField<String>(
                    value: items.contains(value) ? value : null,
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
