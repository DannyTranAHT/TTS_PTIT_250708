import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/res/images/app_images.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.isBack = false});
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 111, 136, 246),
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child:
          isBack
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      SizedBox(width: 8.w),
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: AssetImage(AppImages.avt),
                      ),
                    ],
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: AssetImage(AppImages.avt),
                  ),
                ],
              ),
    );
  }
}
