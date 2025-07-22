import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    required this.onPressed,
    this.isBack = false,
  });
  final String title;
  final bool isBack;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: 393.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      // decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isBack
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF764BA2),
                  size: 24.sp,
                ),
                onPressed: onPressed,
              )
              : SizedBox(width: 24.w),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF764BA2),
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }
}
