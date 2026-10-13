import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_skeleton_box.dart';

class DownloadsLogSkeleton extends StatelessWidget {
  const DownloadsLogSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (BuildContext context, int index) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: <Widget>[
          AppSkeletonBox(height: 26.w, width: 26.w, radius: 6.r),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppSkeletonBox(height: 12.h, width: 170.w),

                SizedBox(height: 8.h),

                AppSkeletonBox(height: 10.h, width: 60.w),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          AppSkeletonBox(height: 22.w, width: 22.w, isCircular: true),
        ],
      ),
    );
  }
}
