import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/screens/project/create_project.dart';
import 'package:project_hub/screens/project/project_detail.dart';
import 'package:project_hub/screens/widgets/bottom_bar.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = [
    'Tất cả',
    'Dự án chưa thực hiện',
    'Dự án đang thực hiện',
    'Dự án đã hoàn thành',
    'Dự án đã hủy',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
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
              Positioned(
                top: 80.h,
                left: 0,
                right: 0,
                bottom: 60.h,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Danh sách dự án',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateProjectScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF8B5FBF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Tạo dự án mới',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            width: double.infinity,
                            height: 44.h,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Color(0xFFE9ECEF),
                                      ),
                                    ),
                                    child: TextField(
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Tìm kiếm dự án...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14.sp,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey[500],
                                          size: 20.sp,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                GestureDetector(
                                  onTap: _showFilterBottomSheet,
                                  child: Container(
                                    width: 44.w,
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Color(0xFFE9ECEF),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.filter_list,
                                      color: Colors.grey[600],
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height - 330.h,
                            child: ListView(
                              children: [
                                _buildProjectCard(
                                  'E-commerce Mobile App',
                                  'Phát triển ứng dụng di động cho hệ thống quản lý bán hàng với tích hợp thanh toán online',
                                  15,
                                  24,
                                  3,
                                  'Hạn: 15/3/2024',
                                  'ĐANG THỰC HIỆN',
                                  Color(0xFF6C63FF),
                                  0.62,
                                ),
                                SizedBox(height: 16.h),
                                _buildProjectCard(
                                  'Mobile App Development',
                                  'Phát triển ứng dụng di động cho hệ thống quản lý bán hàng với tích hợp thanh toán online',
                                  15,
                                  24,
                                  3,
                                  'Hạn: 15/3/2024',
                                  'ĐANG THỰC HIỆN',
                                  Colors.green,
                                  0.62,
                                ),
                                SizedBox(height: 16.h),
                                _buildProjectCard(
                                  'Mobile App Development',
                                  'Phát triển ứng dụng di động cho hệ thống quản lý bán hàng với tích hợp thanh toán online',
                                  15,
                                  24,
                                  3,
                                  'Hạn: 15/3/2024',
                                  'ĐANG THỰC HIỆN',
                                  Color(0xFF6C63FF),
                                  0.62,
                                ),
                                SizedBox(height: 16.h),
                                _buildProjectCard(
                                  'Mobile App Development',
                                  'Phát triển ứng dụng di động cho hệ thống quản lý bán hàng với tích hợp thanh toán online',
                                  15,
                                  24,
                                  3,
                                  'Hạn: 15/3/2024',
                                  'ĐANG THỰC HIỆN',
                                  Color(0xFF6C63FF),
                                  0.62,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(index: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              topRight: Radius.circular(25.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Bộ lọc',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ..._filterOptions.map((option) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = option;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color:
                                  _selectedFilter == option
                                      ? Color(0xFF6C63FF)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    _selectedFilter == option
                                        ? Colors.white
                                        : Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(
    String title,
    String description,
    int completedTasks,
    int totalTasks,
    int members,
    String deadline,
    String status,
    Color statusColor,
    double progress,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ProjectDetailScreen()),
        // );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border(top: BorderSide(color: Color(0xFF6C63FF), width: 3.w)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.smartphone,
                    color: statusColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.task_alt, color: Colors.grey[500], size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$completedTasks/$totalTasks tasks',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey[500], size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$members thành viên',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildAvatarItem('NA', Color(0xFF6C63FF)),
                    Transform.translate(
                      offset: Offset(-8.w, 0),
                      child: _buildAvatarItem('JD', Color(0xFF4CAF50)),
                    ),
                    Transform.translate(
                      offset: Offset(-16.w, 0),
                      child: _buildAvatarItem('JS', Color(0xFFFF9800)),
                    ),
                  ],
                ),
                Text(
                  deadline,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarItem(String initials, Color color) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
