import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_skeleton_list.dart';
import '../../../../core/widgets/loading/skeletons/live_session_tile_skeleton.dart';

/// First-paint state for the live-sessions tab. Padding and gap are
/// `LiveSessionsList`'s.
class LiveSessionsSkeleton extends StatelessWidget {
  const LiveSessionsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonList(
      itemCount: itemCount,
      gap: 12.h,
      padding: EdgeInsets.fromLTRB(
        16.w,
        4.h,
        16.w,
        AppBottomNavBar.barHeight + 24.h,
      ),
      itemBuilder: (BuildContext context) => const LiveSessionTileSkeleton(),
    );
  }
}
