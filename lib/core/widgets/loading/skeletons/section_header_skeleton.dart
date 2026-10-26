import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';
import '../skeleton_text_line.dart';

/// Mirrors `SectionHeader`: title, optional subtitle, optional trailing
/// "view all" chip.
class SectionHeaderSkeleton extends StatelessWidget {
  const SectionHeaderSkeleton({
    super.key,
    this.hasSubtitle = false,
    this.hasAction = false,
  });

  final bool hasSubtitle;
  final bool hasAction;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SkeletonTextLine(fontSize: 18.sp, width: 150.w),

                if (hasSubtitle) ...<Widget>[
                  SizedBox(height: 2.h),

                  SkeletonTextLine(fontSize: 14.sp, width: 96.w),
                ],
              ],
            ),
          ),

          if (hasAction) ...<Widget>[
            SizedBox(width: 12.w),

            // The real chip is 13.sp text inside 6.h/12.w padding plus a hairline.
            SkeletonBox(
              height: 13.sp * 1.5 + 12.h + 2,
              width: 72.w,
              radius: 6.r,
            ),
          ],
        ],
      ),
    );
  }
}
