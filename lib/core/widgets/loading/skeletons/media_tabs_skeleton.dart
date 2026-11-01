import 'package:bilhikma/core/widgets/loading/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaTabsSkeleton extends StatelessWidget {
  const MediaTabsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: SkeletonBox(height: 36.h, radius: 8.r)),
              SizedBox(width: 8.w),
              Expanded(child: SkeletonBox(height: 36.h, radius: 8.r)),
            ],
          ),
          SizedBox(height: 16.h),
          ...List<Widget>.generate(
            4,
            (int index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SkeletonBox(height: 80.h, radius: 12.r),
            ),
          ),
        ],
      ),
    );
  }
}
