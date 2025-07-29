import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/screens/home/home.dart';
import 'package:project_hub/screens/profile/profile.dart';
import 'package:project_hub/screens/project/project.dart';

class BottomBar extends StatefulWidget {
  final int index;
  const BottomBar({super.key, this.index = 1});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            AppImages.homeicon,
            widget.index == 1 ? true : false,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          _buildIconButton(
            AppImages.projecticon,
            widget.index == 2 ? true : false,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectsScreen()),
              );
            },
          ),

          _buildIconButton(
            AppImages.profileicon,
            widget.index == 3 ? true : false,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    String iconPath,
    bool isselected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 70.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isselected
                ? Container(
                  height: 2.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                )
                : SizedBox.shrink(),
            SizedBox(height: 5.h),

            isselected
                ? Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Image.asset(
                    iconPath,
                    color: Colors.white,
                    height: 50.h,
                    width: 50.w,
                  ),
                )
                : Container(
                  width: 60.w,
                  height: 60.h,
                  child: Image.asset(
                    iconPath,
                    color: Color(0xFF764BA2),
                    height: 50.h,
                    width: 50.w,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
