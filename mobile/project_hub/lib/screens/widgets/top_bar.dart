import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/config/api_config.dart';
import 'package:project_hub/providers/auth_provider.dart';
import 'package:project_hub/providers/notification_provider.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/screens/auth/login.dart';
import 'package:project_hub/screens/notifications/notifications_screen.dart';
import 'package:provider/provider.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, this.isBack = false});
  final bool isBack;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notiProvider, child) {
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
              widget.isBack
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
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (notiProvider.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 10.r,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      notiProvider.unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 8.w),
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
                              Icons.login,
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
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (notiProvider.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                radius: 10.r,
                                backgroundColor: Colors.red,
                                child: Text(
                                  notiProvider.unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
