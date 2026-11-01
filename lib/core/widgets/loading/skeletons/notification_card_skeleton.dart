import 'package:bilhikma/core/widgets/loading/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SkeletonBox(
            height: 40,
            width: 40,
            isCircular: true,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: 16.h, width: double.infinity),
                SizedBox(height: 8.h),
                SkeletonBox(height: 12.h, width: 200.w),
                SizedBox(height: 6.h),
                SkeletonBox(height: 10.h, width: 120.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
