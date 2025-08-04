import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/config/status_config.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/screens/project/add_member.dart';
import 'package:project_hub/screens/project/member_list.dart';
import 'package:project_hub/screens/task/task_list.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});
  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  String? token;
  String? refreshToken;
  final List<Map<String, Widget>> _tabs = [
    {
      'name': Text(
        'Thêm thành viên',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      'icon': Icon(Icons.people, size: 30.sp),
    },
    {
      'name': Text(
        'Thống kê',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      'icon': Icon(Icons.bar_chart, size: 30.sp),
    },
    {
      'name': Text(
        'Cài đặt',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      'icon': Icon(Icons.settings, size: 30.sp),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final loadedToken = await StorageService.getToken();
      final loadedRefreshToken = await StorageService.getRefreshToken();

      setState(() {
        token = loadedToken;
        refreshToken = loadedRefreshToken;
      });

      if (token != null && mounted) {
        final projectProvider = Provider.of<ProjectProvider>(
          context,
          listen: false,
        );
        await projectProvider.fetchProject(widget.project.id ?? '', token!);
      }
    } catch (e) {
      print('Error initializing: $e');
    }
  }

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
          child: Consumer<ProjectProvider>(
            builder: (context, projectProvider, child) {
              if (projectProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (projectProvider.errorMessage != null) {
                return Center(child: Text(projectProvider.errorMessage!));
              }
              final project = projectProvider.selectedProject;
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopBar(isBack: true),
                  ),
                  Positioned(
                    top: 80.h,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Project Header
                              Row(
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6C63FF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Icon(
                                      Icons.folder_open,
                                      color: Color(0xFF6C63FF),
                                      size: 30.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project?.name ?? 'Project Name Here',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: StatusConfig.statusColor(
                                              project?.status ?? 'Not Started',
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                          child: Text(
                                            StatusConfig.changeStatus(
                                              project?.status ?? 'Not Started',
                                            ),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: StatusConfig.statusColor(
                                                project?.status ??
                                                    'Not Started',
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Tab Bar
                              Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(_tabs.length, (
                                    index,
                                  ) {
                                    return InkWell(
                                      onTap: () {
                                        if (index == 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AddMemberScreen(
                                                    projectId:
                                                        project!.id ?? '',
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 108.w,
                                        height: 100.h,
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _tabs[index]['icon']!,
                                            SizedBox(height: 4.h),
                                            _tabs[index]['name']!,
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Project Description
                              Text(
                                'Thông tin dự án',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                project?.description ??
                                    'No description available.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Statistics Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      project?.numTasks.toString() ?? '0',
                                      'TỔNG TASKS',
                                      'Xem',
                                      () {},
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      project?.numCompletedTasks.toString() ??
                                          '0',
                                      'HOÀN THÀNH',
                                      'Xem',
                                      () {},
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      project!.members?.length.toString() ??
                                          '0',
                                      'THÀNH VIÊN',
                                      'Xem',
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => MemberListScreen(
                                                  project: project!,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      _getRemainingText(project.endDate),
                                      'NGÀY CÒN LẠI',
                                      '',
                                      () {},
                                      textColor: _getRemainingColor(
                                        project.endDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),

                              // Progress Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tiến độ dự án',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  Text(
                                    project.numTasks == 0
                                        ? '0 %'
                                        : '${(project.numCompletedTasks / project.numTasks * 100).round()} %',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                width: double.infinity,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      project.numTasks == 0
                                          ? 0 / 1
                                          : (project.numCompletedTasks /
                                              project.numTasks),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Additional Information Section
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin thêm',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildInfoRow(
                                      'NGÀY BẮT ĐẦU',
                                      '${project.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildInfoRow(
                                      'NGÀY KẾT THÚC',
                                      '${project.endDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildInfoRow(
                                      'PROJECT MANAGER',
                                      project.owner?.fullName ?? 'N/A',
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildInfoRow(
                                      'BUDGET',
                                      '${project.budget?.toString() ?? 'N/A'}',
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String title,
    String action,
    VoidCallback onTap, {
    Color textColor = const Color(0xFF2D2D2D),
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // hàm xử lý ngày
  String _getRemainingText(DateTime? endDate) {
    if (endDate == null) return 'N/A';
    final int days = endDate.difference(DateTime.now()).inDays;
    return days < 0 ? 'Hết hạn' : '$days';
  }

  Color _getRemainingColor(DateTime? endDate) {
    if (endDate == null) return Color(0xFF2D2D2D);
    final int days = endDate.difference(DateTime.now()).inDays;
    return days < 0 ? Colors.red : Color(0xFF2D2D2D);
  }
}
