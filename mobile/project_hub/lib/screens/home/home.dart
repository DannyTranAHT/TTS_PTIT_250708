import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/user_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/screens/widgets/bottom_bar.dart';
import 'package:project_hub/screens/widgets/project_card.dart';
import 'package:project_hub/screens/widgets/stat_card.dart';
import 'package:project_hub/screens/widgets/task_card.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  String? refreshToken;
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load data from storage
      final loadedToken = await StorageService.getToken();
      final loadedRefreshToken = await StorageService.getRefreshToken();
      final loadedUser = await StorageService.getUser();

      setState(() {
        token = loadedToken;
        refreshToken = loadedRefreshToken;
        user = loadedUser;
        isLoading = false;
      });

      print('HomeScreen initialized with token: $token');
      print('User: ${user?.fullName}');

      // Fetch projects after loading token
      if (token != null && mounted) {
        final projectProvider = Provider.of<ProjectProvider>(
          context,
          listen: false,
        );
        await projectProvider.fetchProjects(token!);
      }
    } catch (e) {
      print('Error initializing HomeScreen: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                bottom: 80.h,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 250, 250),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.maxFinite,
                            height: 120.h,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Chào mừng trở lại! ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '👋',
                                      style: TextStyle(fontSize: 18.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Bạn có 5 dự án đang hoạt động và 12\ntask cần hoàn thành',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Thống kê dự án
                          Container(
                            height: 230.h,
                            child: Consumer<ProjectProvider>(
                              builder: (context, projectProvider, child) {
                                if (projectProvider.isLoading) {
                                  return Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StatCard(
                                            title: 'DỰ ÁN',
                                            value:
                                                '${projectProvider.numProjects}',
                                            subtitle:
                                                '+${projectProvider.numberInWeek} tuần này',
                                            color: Color(0xFF4CAF50),
                                            icon: Icons.folder_outlined,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: StatCard(
                                            title: 'TASK TỔNG',
                                            value: '19',
                                            subtitle: '+7 hôm nay',
                                            color: Color(0xFF2196F3),
                                            icon: Icons.task_alt_outlined,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12.h),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: StatCard(
                                            title: 'HOÀN THÀNH',
                                            value:
                                                '${projectProvider.numCompletedProjects}',
                                            subtitle:
                                                '${(projectProvider.numCompletedProjects / projectProvider.numProjects * 100).round()}% tỷ lệ',
                                            color: Color(0xFFFF9800),
                                            icon: Icons.check_circle_outline,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: StatCard(
                                            title: 'QUÁ HẠN',
                                            value:
                                                '${projectProvider.numOverdueProjects}',
                                            subtitle: '1 từ hôm qua',
                                            color: Color(0xFFF44336),
                                            icon: Icons.access_time,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 18.h),

                          // Dự án gần đây
                          Container(
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: 5.h,
                              bottom: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Dự án gần đây',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Xem tất cả',
                                        style: TextStyle(
                                          color: Color(0xFF6C63FF),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 260.h,
                                  child: ListView(
                                    children: [
                                      ProjectCard(
                                        title: 'Mobile App Development',
                                        members: '5',
                                        tasks: '10',
                                        status: 'ĐANG THỰC HIỆN',
                                        statusColor: Color(0xFF4CAF50),
                                        progress: 0.7,
                                      ),
                                      SizedBox(height: 12.h),
                                      ProjectCard(
                                        title: 'API Integration',
                                        members: '3',
                                        tasks: '5',
                                        status: 'QUÁ HẠN',
                                        statusColor: Color(0xFFF44336),
                                        progress: 0.4,
                                      ),
                                      SizedBox(height: 10.h),
                                      ProjectCard(
                                        title: 'Website Redesign',
                                        members: '4',
                                        tasks: '8',
                                        status: 'HOÀN THÀNH',
                                        statusColor: Color(0xFF2196F3),
                                        progress: 1.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 27.h),
                          // Task của tôi
                          Container(
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: 5.h,
                              bottom: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Task của tôi',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Xem tất cả',
                                        style: TextStyle(
                                          color: Color(0xFF6C63FF),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 260.h,
                                  child: ListView(
                                    children: [
                                      TaskCard(
                                        title: 'Thiết kế giao diện ứng dụng',
                                        project: 'Mobile App Development',
                                        deadline: '20/10',
                                        status: 'ĐANG THỰC HIỆN',
                                        statusColor: Color(0xFF4CAF50),
                                      ),
                                      SizedBox(height: 12.h),
                                      TaskCard(
                                        title: 'Phát triển API cho ứng dụng',
                                        project: 'API Integration',
                                        deadline: '25/10',
                                        status: 'QUÁ HẠN',
                                        statusColor: Color(0xFFF44336),
                                      ),
                                      SizedBox(height: 12.h),
                                      TaskCard(
                                        title: 'Kiểm tra và sửa lỗi website',
                                        project: 'Website Redesign',
                                        deadline: '30/10',
                                        status: 'HOÀN THÀNH',
                                        statusColor: Color(0xFF2196F3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(index: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
