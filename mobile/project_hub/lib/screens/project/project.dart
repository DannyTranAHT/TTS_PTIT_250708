import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/models/project_model.dart';
import 'package:project_hub/providers/project_provider.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/screens/project/create_project.dart';
import 'package:project_hub/screens/project/project_detail.dart';
import 'package:project_hub/screens/widgets/bottom_bar.dart';
import 'package:project_hub/screens/widgets/project_card_all.dart';
import 'package:project_hub/screens/widgets/top_bar.dart';
import 'package:project_hub/services/storage_service.dart';
import 'package:provider/provider.dart';

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? token;
  String? refreshToken;
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = [
    'Tất cả',
    'Dự án chưa thực hiện',
    'Dự án đang thực hiện',
    'Dự án đã hoàn thành',
    'Dự án đã hủy',
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
        await projectProvider.fetchProjects(token!);
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
                          Consumer<ProjectProvider>(
                            builder: (context, projectProvider, child) {
                              if (projectProvider.isLoading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (projectProvider.projects.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Không có dự án nào',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }
                              if (projectProvider.errorMessage != null) {
                                return Center(
                                  child: Text(
                                    projectProvider.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              // Lọc danh sách dự án dựa trên bộ lọc được chọn
                              final filteredProjects = _filterProjects(
                                projectProvider.projects,
                              );

                              if (filteredProjects.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Không có dự án nào phù hợp với bộ lọc',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height - 330.h,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final project = filteredProjects[index];
                                    return ProjectCardAll(project: project);
                                  },
                                  itemCount: filteredProjects.length,
                                ),
                              );
                            },
                          ),
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

  List<Project> _filterProjects(List<Project> projects) {
    switch (_selectedFilter) {
      case 'Dự án chưa thực hiện':
        return projects
            .where((project) => project.status == 'Not Started')
            .toList();
      case 'Dự án đang thực hiện':
        return projects
            .where((project) => project.status == 'In Progress')
            .toList();
      case 'Dự án đã hoàn thành':
        return projects
            .where((project) => project.status == 'Completed')
            .toList();
      case 'Dự án đã hủy':
        return projects
            .where((project) => project.status == 'Cancelled')
            .toList();
      case 'Tất cả':
      default:
        return projects;
    }
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
}
