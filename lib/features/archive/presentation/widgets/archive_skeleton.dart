import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_skeleton_list.dart';
import '../../../../core/widgets/loading/skeletons/lesson_card_skeleton.dart';

/// First-paint state for the saved-items tab. Padding and gap are
/// `ArchiveContent`'s, so nothing shifts when the list lands.
class ArchiveSkeleton extends StatelessWidget {
  const ArchiveSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonList(
      itemCount: itemCount,
      gap: 16.h,
      padding: EdgeInsets.fromLTRB(
        16.w,
        20.h,
        16.w,
        AppBottomNavBar.barHeight + 20.h,
      ),
      itemBuilder: (BuildContext context) => const LessonCardSkeleton(),
    );
  }
}
