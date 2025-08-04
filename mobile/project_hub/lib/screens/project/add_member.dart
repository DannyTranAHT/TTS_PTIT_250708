// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:project_hub/models/user_model.dart';
// import 'package:project_hub/screens/widgets/top_bar.dart';

// class AddMemberScreen extends StatefulWidget {
//   @override
//   _AddMemberScreenState createState() => _AddMemberScreenState();
// }

// class _AddMemberScreenState extends State<AddMemberScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _scrollController = ScrollController();
//   final _emailFocusNode = FocusNode();

//   List<User> _searchResults = [];
//   bool _isSearching = false;
//   bool _hasSearched = false;
//   User? _selectedUser;

//   @override
//   void initState() {
//     super.initState();
//     _emailFocusNode.addListener(() {
//       if (_emailFocusNode.hasFocus) {
//         _scrollToShowField(200.h);
//       }
//     });
//   }

//   void _scrollToShowField(double offset) {
//     Future.delayed(Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           offset,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _scrollController.dispose();
//     _emailFocusNode.dispose();
//     super.dispose();
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Vui lòng nhập email';
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value.trim())) {
//       return 'Email không hợp lệ';
//     }
//     return null;
//   }

//   void _searchUser() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSearching = true;
//         _hasSearched = false;
//         _selectedUser = null;
//       });

//       // Simulate search delay
//       Future.delayed(Duration(seconds: 1), () {
//         final email = _emailController.text.trim().toLowerCase();
//         final results =
//             User.searchableUsers
//                 .where((user) => user.email.toLowerCase().contains(email))
//                 .toList();

//         setState(() {
//           _searchResults = results;
//           _isSearching = false;
//           _hasSearched = true;
//         });
//       });
//     }
//   }

//   void _selectUser(User user) {
//     setState(() {
//       _selectedUser = user;
//     });
//   }

//   void _addMember() {
//     if (_selectedUser != null) {
//       // Thêm thành viên vào dự án (mock)
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
//             ),
//           );
//         },
//       );

//       Future.delayed(Duration(seconds: 1), () {
//         Navigator.of(context).pop();

//         // Thêm vào danh sách members (mock)
//         User.mockUsers.add(
//           User(
//             id: 'ss',
//             name: _selectedUser!.name,
//             email: _selectedUser!.email,
//             role: _selectedUser!.role,
//             username: _selectedUser!.username,
//             joinedDate: DateTime.now(),
//           ),
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Đã thêm ${_selectedUser!.name} vào dự án thành công!',
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );

//         // Reset form
//         setState(() {
//           _emailController.clear();
//           _searchResults.clear();
//           _hasSearched = false;
//           _selectedUser = null;
//         });
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xFFF5F5F5),
//         resizeToAvoidBottomInset: true,
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//             ),
//           ),
//           child: Column(
//             children: [
//               TopBar(isBack: true),

//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(color: Colors.white),
//                   child: Form(
//                     key: _formKey,
//                     child: SingleChildScrollView(
//                       controller: _scrollController,
//                       padding: EdgeInsets.all(20.r),
//                       child: Container(
//                         margin: EdgeInsets.only(
//                           bottom: keyboardHeight > 0 ? 20.h : 0,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 20.h),

//                             // Search Section
//                             Text(
//                               'Tìm kiếm thành viên',
//                               style: TextStyle(
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF2D2D2D),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             Text(
//                               'Nhập email để tìm kiếm và thêm thành viên mới vào dự án',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             SizedBox(height: 24.h),

//                             // Email Input
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Email thành viên',
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xFF2D2D2D),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFF8F9FA),
//                                     borderRadius: BorderRadius.circular(12.r),
//                                     border: Border.all(
//                                       color: Color(0xFFE9ECEF),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextFormField(
//                                           controller: _emailController,
//                                           focusNode: _emailFocusNode,
//                                           validator: _validateEmail,
//                                           keyboardType:
//                                               TextInputType.emailAddress,
//                                           textInputAction:
//                                               TextInputAction.search,
//                                           onFieldSubmitted:
//                                               (_) => _searchUser(),
//                                           style: TextStyle(
//                                             fontSize: 14.sp,
//                                             color: Color(0xFF2D2D2D),
//                                           ),
//                                           decoration: InputDecoration(
//                                             hintText: 'Nhập email người dùng',
//                                             hintStyle: TextStyle(
//                                               color: Colors.grey[500],
//                                               fontSize: 14.sp,
//                                             ),
//                                             border: InputBorder.none,
//                                             contentPadding:
//                                                 EdgeInsets.symmetric(
//                                                   horizontal: 16.w,
//                                                   vertical: 16.h,
//                                                 ),
//                                             errorStyle: TextStyle(
//                                               fontSize: 12.sp,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.all(4.r),
//                                         child: ElevatedButton(
//                                           onPressed:
//                                               _isSearching ? null : _searchUser,
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Color(0xFF6C63FF),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8.r),
//                                             ),
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: 16.w,
//                                               vertical: 12.h,
//                                             ),
//                                           ),
//                                           child:
//                                               _isSearching
//                                                   ? SizedBox(
//                                                     width: 16.w,
//                                                     height: 16.h,
//                                                     child: CircularProgressIndicator(
//                                                       strokeWidth: 2,
//                                                       valueColor:
//                                                           AlwaysStoppedAnimation<
//                                                             Color
//                                                           >(Colors.white),
//                                                     ),
//                                                   )
//                                                   : Text(
//                                                     'Tìm',
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 14.sp,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             SizedBox(height: 32.h),

//                             // Search Results
//                             if (_hasSearched) ...[
//                               Text(
//                                 'Kết quả tìm kiếm',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF2D2D2D),
//                                 ),
//                               ),
//                               SizedBox(height: 16.h),

//                               if (_searchResults.isEmpty)
//                                 Container(
//                                   width: double.infinity,
//                                   padding: EdgeInsets.all(24.r),
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFF8F9FA),
//                                     borderRadius: BorderRadius.circular(12.r),
//                                     border: Border.all(
//                                       color: Color(0xFFE9ECEF),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Icon(
//                                         Icons.search_off,
//                                         size: 48.sp,
//                                         color: Colors.grey[400],
//                                       ),
//                                       SizedBox(height: 12.h),
//                                       Text(
//                                         'Không tìm thấy người dùng',
//                                         style: TextStyle(
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                       SizedBox(height: 4.h),
//                                       Text(
//                                         'Vui lòng thử lại với email khác',
//                                         style: TextStyle(
//                                           fontSize: 14.sp,
//                                           color: Colors.grey[500],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               else
//                                 ...(_searchResults
//                                     .map((user) => _buildUserCard(user))
//                                     .toList()),

//                               SizedBox(height: 32.h),
//                             ],

//                             // Selected User & Add Button
//                             if (_selectedUser != null) ...[
//                               Text(
//                                 'Thành viên được chọn',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF2D2D2D),
//                                 ),
//                               ),
//                               SizedBox(height: 12.h),
//                               Container(
//                                 padding: EdgeInsets.all(16.r),
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFF6C63FF).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: Color(0xFF6C63FF).withOpacity(0.3),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 24.r,
//                                       backgroundColor: Color(0xFF6C63FF),
//                                       child: Text(
//                                         _selectedUser!.name[0].toUpperCase(),
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 12.w),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             _selectedUser!.name,
//                                             style: TextStyle(
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.w600,
//                                               color: Color(0xFF2D2D2D),
//                                             ),
//                                           ),
//                                           SizedBox(height: 2.h),
//                                           Text(
//                                             _selectedUser!.email,
//                                             style: TextStyle(
//                                               fontSize: 14.sp,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           SizedBox(height: 4.h),
//                                           Container(
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: 8.w,
//                                               vertical: 4.h,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: Color(0xFF6C63FF),
//                                               borderRadius:
//                                                   BorderRadius.circular(12.r),
//                                             ),
//                                             child: Text(
//                                               _selectedUser!.role,
//                                               style: TextStyle(
//                                                 fontSize: 10.sp,
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 24.h),

//                               // Add Member Button
//                               Container(
//                                 width: double.infinity,
//                                 height: 56.h,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Color(0xFF6C63FF),
//                                       Color(0xFF8B5FBF),
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(12.r),
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: _addMember,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.transparent,
//                                     shadowColor: Colors.transparent,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Thêm vào dự án',
//                                     style: TextStyle(
//                                       fontSize: 18.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],

//                             SizedBox(height: keyboardHeight > 0 ? 100.h : 0),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserCard(User user) {
//     final isSelected = _selectedUser?.id == user.id;

//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       child: InkWell(
//         onTap: () => _selectUser(user),
//         child: Container(
//           padding: EdgeInsets.all(16.r),
//           decoration: BoxDecoration(
//             color:
//                 isSelected ? Color(0xFF6C63FF).withOpacity(0.1) : Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: isSelected ? Color(0xFF6C63FF) : Color(0xFFE9ECEF),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 24.r,
//                 backgroundColor:
//                     isSelected ? Color(0xFF6C63FF) : Colors.grey[400],
//                 child: Text(
//                   user.name[0].toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.name,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2D2D2D),
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       user.email,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected ? Color(0xFF6C63FF) : Colors.grey[400],
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Text(
//                         user.role,
//                         style: TextStyle(
//                           fontSize: 10.sp,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 24.sp),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
