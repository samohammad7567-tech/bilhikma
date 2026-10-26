import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/app_skeleton_list.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';

class DownloadsLogSkeleton extends StatelessWidget {
  const DownloadsLogSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonList(
      itemCount: itemCount,
      itemBuilder: (BuildContext context) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.tertiaryContainer;

    return AppShimmer(
      child: Container(
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: <Widget>[
            SkeletonBox(
              height: 26.w,
              width: 26.w,
              radius: 6.r,
              surface: surface,
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SkeletonBox(height: 12.h, width: 170.w, surface: surface),

                  SizedBox(height: 8.h),

                  SkeletonBox(height: 10.h, width: 60.w, surface: surface),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            SkeletonBox(
              height: 22.w,
              width: 22.w,
              isCircular: true,
              surface: surface,
            ),
          ],
        ),
      ),
    );
  }
}
