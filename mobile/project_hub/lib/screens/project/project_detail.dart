// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:project_hub/screens/project/add_member.dart';
// import 'package:project_hub/screens/project/member_list.dart';
// import 'package:project_hub/screens/task/task_list.dart';
// import 'package:project_hub/screens/widgets/top_bar.dart';

// class ProjectDetailScreen extends StatefulWidget {
//   @override
//   _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
// }

// class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
//   final List<Map<String, Widget>> _tabs = [
//     {
//       'name': Text(
//         'Thêm thành viên',
//         style: TextStyle(
//           fontSize: 12.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),
//       ),
//       'icon': Icon(Icons.people, size: 30.sp),
//     },
//     {
//       'name': Text(
//         'Thống kê',
//         style: TextStyle(
//           fontSize: 12.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),
//       ),
//       'icon': Icon(Icons.bar_chart, size: 30.sp),
//     },
//     {
//       'name': Text(
//         'Cài đặt',
//         style: TextStyle(
//           fontSize: 12.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),
//       ),
//       'icon': Icon(Icons.settings, size: 30.sp),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: TopBar(isBack: true),
//               ),

//               Positioned(
//                 top: 80.h,
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: SingleChildScrollView(
//                   child: Container(
//                     width: double.infinity,

//                     decoration: BoxDecoration(color: Colors.white),
//                     child: Padding(
//                       padding: EdgeInsets.all(20.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Project Header
//                           Row(
//                             children: [
//                               Container(
//                                 width: 60.w,
//                                 height: 60.w,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFF6C63FF).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(16.r),
//                                 ),
//                                 child: Icon(
//                                   Icons.smartphone,
//                                   color: Color(0xFF6C63FF),
//                                   size: 30.sp,
//                                 ),
//                               ),
//                               SizedBox(width: 16.w),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Mobile App Development',
//                                       style: TextStyle(
//                                         fontSize: 20.sp,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF2D2D2D),
//                                       ),
//                                     ),
//                                     SizedBox(height: 4.h),
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: 12.w,
//                                         vertical: 6.h,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Color(
//                                           0xFF6C63FF,
//                                         ).withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(
//                                           16.r,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         'ĐANG THỰC HIỆN',
//                                         style: TextStyle(
//                                           fontSize: 10.sp,
//                                           color: Color(0xFF6C63FF),
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20.h),
//                           // Tab Bar
//                           Container(
//                             height: 100.h,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: List.generate(_tabs.length, (index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     // Handle tab selection
//                                     if (index == 0) {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder:
//                                               (context) => AddMemberScreen(),
//                                         ),
//                                       );
//                                     } else if (index == 1) {
//                                     } else if (index == 2) {}
//                                   },
//                                   child: Container(
//                                     width: 108.w,
//                                     height: 100.h,
//                                     padding: EdgeInsets.all(10.sp),
//                                     decoration: BoxDecoration(
//                                       color: Color.fromARGB(255, 255, 255, 255),
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.1),
//                                           spreadRadius: 2,
//                                           blurRadius: 4,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         _tabs[index]['icon']!,
//                                         SizedBox(height: 4.h),
//                                         _tabs[index]['name']!,
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                           ),

//                           SizedBox(height: 24.h),

//                           // Project Description
//                           Text(
//                             'Thông tin dự án',
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF2D2D2D),
//                             ),
//                           ),
//                           SizedBox(height: 12.h),
//                           Text(
//                             'Phát triển ứng dụng di động cho hệ thống quản lý bán hàng với tích hợp thanh toán online, hỗ trợ đa nền tảng và tối ưu hóa trải nghiệm người dùng.',
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               color: Colors.grey[600],
//                               height: 1.5,
//                             ),
//                           ),

//                           SizedBox(height: 24.h),

//                           // Statistics Row
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildStatCard(
//                                   '24',
//                                   'TỔNG TASKS',
//                                   'Xem',
//                                   () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => TaskListScreen(),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Expanded(
//                                 child: _buildStatCard(
//                                   '15',
//                                   'HOÀN THÀNH',
//                                   'Xem',
//                                   () {
//                                     // Handle view completed tasks
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 12.h),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildStatCard(
//                                   '5',
//                                   'THÀNH VIÊN',
//                                   'Xem',
//                                   () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder:
//                                             (context) => MemberListScreen(),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Expanded(
//                                 child: _buildStatCard(
//                                   '12',
//                                   'NGÀY CÒN LẠI',
//                                   'Xem',
//                                   () {
//                                     // Handle view remaining days
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

//                           SizedBox(height: 24.h),

//                           // Progress Section
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Tiến độ dự án',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF2D2D2D),
//                                 ),
//                               ),
//                               Text(
//                                 '65%',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF6C63FF),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 12.h),
//                           Container(
//                             width: double.infinity,
//                             height: 8.h,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(4.r),
//                             ),
//                             child: FractionallySizedBox(
//                               alignment: Alignment.centerLeft,
//                               widthFactor: 0.65,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFF4CAF50),
//                                   borderRadius: BorderRadius.circular(4.r),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 24.h),

//                           // Additional Information Section
//                           Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF8F9FA),
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Thông tin thêm',
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF2D2D2D),
//                                   ),
//                                 ),
//                                 SizedBox(height: 16.h),
//                                 _buildInfoRow('NGÀY BẮT ĐẦU', '10/01/2024'),
//                                 SizedBox(height: 12.h),
//                                 _buildInfoRow('NGÀY KẾT THÚC', '15/03/2024'),
//                                 SizedBox(height: 12.h),
//                                 _buildInfoRow('PROJECT MANAGER', 'John Doe'),
//                                 SizedBox(height: 12.h),
//                                 _buildInfoRow('BUDGET', '\$50,000'),
//                                 SizedBox(height: 12.h),
//                                 _buildInfoRow('CLIENT', 'ABC Company'),
//                               ],
//                             ),
//                           ),
//                         ],
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

//   Widget _buildStatCard(
//     String value,
//     String title,
//     String action,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: Color(0xFFE9ECEF)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 28.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8.h),
//             GestureDetector(
//               onTap: () {},
//               child: Text(
//                 action,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Color(0xFF6C63FF),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Color(0xFF2D2D2D),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }
