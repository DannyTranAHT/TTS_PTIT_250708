import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/screens/auth/login.dart';
import 'package:project_hub/screens/auth/register.dart';
import 'package:project_hub/screens/auth/register2.dart';
import 'package:project_hub/screens/start/start.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 802), // Kích thước từ Figma
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Project Hub',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            fontFamily: 'Roboto',
            textTheme: Typography.englishLike2021.apply(fontSizeFactor: 1.sp),
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/register1': (context) => RegisterScreen(),
            '/register2': (context) => RegisterScreen2(),
            '/splash': (context) => SplashScreen(),
          },
        );
      },
    );
  }
}
