import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/config/api_config.dart';
import 'package:project_hub/providers/auth_provider.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/screens/auth/login.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.isBack = false});
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: () {
                              authProvider.logout();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 24.sp,
                            ),
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage:
                                (authProvider.user?.avatar == "None" ||
                                        authProvider.errorMessage != null)
                                    ? AssetImage(AppImages.avt)
                                    : NetworkImage(
                                      '${ApiConfig.socketUrl}/${authProvider.user!.avatar!}',
                                    ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: () {
                              authProvider.logout();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
