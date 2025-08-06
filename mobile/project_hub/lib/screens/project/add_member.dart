import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/models/user_model.dart';
import 'package:project_hub/providers/auth_provider.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget {
  final Project project;
  const AddMemberScreen({Key? key, required this.project}) : super(key: key);
  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _scrollController = ScrollController();
  final _emailFocusNode = FocusNode();

  User? _selectedUser;
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _scrollToShowField(200.h);
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
    _emailController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Future<void> _searchUser(String email) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    User? user = await authProvider.searchUserByEmail(email);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy người dùng với email này'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } else {
      setState(() {
        _selectedUser = user;
        _hasSearched = true;
      });
    }
  }

  Future<void> _addMember() async {
    if (_selectedUser != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện thao tác này'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_selectedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng tìm kiếm người dùng trước'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      // Check if the user is the project owner
      if (_selectedUser!.id == widget.project.owner?.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể thêm chủ sở hữu dự án'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      //Check if the user is already a member
      if (widget.project.members!.any(
        (member) => member.id == _selectedUser!.id,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Người dùng đã là thành viên của dự án này'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final success = await projectProvider.addMemberToProject(
        id: widget.project.id ?? '',
        userId: _selectedUser?.id ?? '',
        token: token,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm thành viên thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm thành viên thất bại'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
          child: Column(
            children: [
              TopBar(isBack: true),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(20.r),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: keyboardHeight > 0 ? 20.h : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Search Section
                            Text(
                              'Tìm kiếm thành viên',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Nhập email để tìm kiếm và thêm thành viên mới vào dự án',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Email Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email thành viên',
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
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Color(0xFFE9ECEF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _emailController,
                                          focusNode: _emailFocusNode,
                                          validator: _validateEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction:
                                              TextInputAction.search,
                                          onFieldSubmitted: (value) async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isSearching = true;
                                              });
                                              await _searchUser(value.trim());
                                              setState(() {
                                                _isSearching = false;
                                              });
                                            }
                                          },
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Nhập email người dùng',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14.sp,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 16.h,
                                                ),
                                            errorStyle: TextStyle(
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(4.r),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isSearching = true;
                                              });
                                              await _searchUser(
                                                _emailController.text.trim(),
                                              );
                                              setState(() {
                                                _isSearching = false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF6C63FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          child:
                                              _isSearching
                                                  ? SizedBox(
                                                    width: 16.w,
                                                    height: 16.h,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Text(
                                                    'Tìm',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 32.h),

                            // Search Results
                            if (_hasSearched) ...[
                              Text(
                                'Kết quả tìm kiếm',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              if (_selectedUser == null) ...[
                                Text(
                                  'Không tìm thấy người dùng nào phù hợp',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ] else ...[
                                _buildUserCard(_selectedUser!),
                              ],
                              SizedBox(height: 80.h),
                              // Add Member Button
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
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _addMember();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Thêm vào dự án',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],

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

  Widget _buildUserCard(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFF6C63FF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              user.avatar == 'None'
                  ? CircleAvatar(
                    radius: 24.r,
                    backgroundColor: Color(0xFF6C63FF),
                    child: Text(
                      '${user.fullName[0].toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : CircleAvatar(
                    radius: 24.r,
                    backgroundImage: NetworkImage(user.avatar ?? ''),
                  ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.fullName}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 24.sp),
            ],
          ),
        ),
      ),
    );
  }
}
