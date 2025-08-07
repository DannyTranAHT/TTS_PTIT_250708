import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/user_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/providers/task_provider.dart';
import 'package:project_hub/screens/project/project.dart';
import 'package:project_hub/screens/project/project_detail.dart';
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

      // Fetch projects after loading token
      if (token != null && mounted) {
        final projectProvider = Provider.of<ProjectProvider>(
          context,
          listen: false,
        );
        await projectProvider.fetchProjects(token!);
        await projectProvider.fetchRecentProjects(token!);

        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.fetchMyTasks(token!);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
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
                child: RefreshIndicator(
                  onRefresh: _initializeData,
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
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
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
                                    'Bạn có ${projectProvider.numProjects} dự án đang hoạt động và ${taskProvider.myTasks.length} task cần hoàn thành',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Thống kê dự án - CHỈ SỬA: Consumer thành Consumer2
                            Container(
                              height: 230.h,
                              child: Consumer2<ProjectProvider, TaskProvider>(
                                builder: (
                                  context,
                                  projectProvider,
                                  taskProvider,
                                  child,
                                ) {
                                  if (projectProvider.isLoading ||
                                      taskProvider.isLoading) {
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (projectProvider.state ==
                                      ProjectState.error) {
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Lỗi tải dữ liệu',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              projectProvider.errorMessage ??
                                                  'Unknown error',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (token != null) {
                                                  await projectProvider
                                                      .fetchProjects(token!);
                                                }
                                              },
                                              child: Text('Thử lại'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  // Safe calculation with null checks
                                  final totalProjects =
                                      projectProvider.numProjects;
                                  final completedProjects =
                                      projectProvider.numCompletedProjects;
                                  final overdueProjects =
                                      projectProvider.numOverdueProjects;
                                  final weekProjects =
                                      projectProvider.numberInWeek;

                                  // Calculate completion percentage safely
                                  final completionPercentage =
                                      totalProjects > 0
                                          ? (completedProjects /
                                                  totalProjects *
                                                  100)
                                              .round()
                                          : 0;

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StatCard(
                                              title: 'DỰ ÁN',
                                              value: '$totalProjects',
                                              subtitle:
                                                  '+$weekProjects tuần này',
                                              color: Color(0xFF4CAF50),
                                              icon: Icons.folder_outlined,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: StatCard(
                                              title: 'TASK TỔNG',
                                              value:
                                                  '${taskProvider.myTasks.length}',
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
                                              value: '$completedProjects',
                                              subtitle:
                                                  '$completionPercentage% tỷ lệ',
                                              color: Color(0xFFFF9800),
                                              icon: Icons.check_circle_outline,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: StatCard(
                                              title: 'QUÁ HẠN',
                                              value: '$overdueProjects',
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

                                  if (projectProvider.state ==
                                      ProjectState.error) {
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Lỗi tải dữ liệu',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              projectProvider.errorMessage ??
                                                  'Unknown error',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (token != null) {
                                                  await projectProvider
                                                      .fetchProjects(token!);
                                                }
                                              },
                                              child: Text('Thử lại'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
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
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ProjectsScreen(),
                                                ),
                                              );
                                            },
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
                                      projectProvider.recentProjects.isEmpty
                                          ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.folder_open,
                                                  size: 32.sp,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(height: 8.h),
                                                Text(
                                                  'Chưa có dự án gần đây',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                              ],
                                            ),
                                          )
                                          : Container(
                                            height: 260.h,
                                            child: ListView.builder(
                                              itemCount:
                                                  projectProvider
                                                      .recentProjects
                                                      .length,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                if (index >=
                                                    projectProvider
                                                        .recentProjects
                                                        .length) {
                                                  return SizedBox.shrink();
                                                }

                                                final project =
                                                    projectProvider
                                                        .recentProjects[index];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8.h,
                                                  ),
                                                  child: ProjectCard(
                                                    title: project.name,
                                                    members:
                                                        project.members?.length
                                                            .toString() ??
                                                        '0',
                                                    tasks:
                                                        project.numTasks
                                                            .toString(),
                                                    status: project.status,
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  ProjectDetailScreen(
                                                                    project:
                                                                        project,
                                                                  ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    ],
                                  );
                                },
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ProjectsScreen(),
                                            ),
                                          );
                                        },
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
                                  taskProvider.myTasks.length == 0
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.task_alt_outlined,
                                              size: 32.sp,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              'Chưa có task nào',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                          ],
                                        ),
                                      )
                                      : Container(
                                        height: 260.h,
                                        child: ListView.builder(
                                          itemCount:
                                              taskProvider.myTasks.length,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            if (index >=
                                                taskProvider.myTasks.length) {
                                              return SizedBox.shrink();
                                            }

                                            final task =
                                                taskProvider.myTasks[index];
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 8.h,
                                              ),
                                              child: TaskCard(task: task),
                                            );
                                          },
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
