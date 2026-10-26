import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';
import '../../../../core/widgets/loading/skeletons/notification_card_skeleton.dart';

/// First-paint state for the notifications tab: the filter pills, a day
/// header, then cards — the same vertical rhythm as `NotificationsList`.
class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
            child: const _FilterTabsSkeleton(),
          ),

          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                0,
                16.w,
                AppBottomNavBar.barHeight + 24.h,
              ),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
                  child: AppShimmer(
                    child: SkeletonTextLine(fontSize: 14.sp, width: 90.w),
                  ),
                ),

                for (int index = 0; index < itemCount; index++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: const NotificationCardSkeleton(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabsSkeleton extends StatelessWidget {
  const _FilterTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    // The real pill is 13.sp text inside 9.h vertical padding plus its border.
    final double height = 13.sp * 1.5 + 18.h + 2;

    return AppShimmer(
      child: Row(
        children: <Widget>[
          Expanded(
            child: SkeletonBox(height: height, radius: height / 2),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: SkeletonBox(height: height, radius: height / 2),
          ),
        ],
      ),
    );
  }
}
