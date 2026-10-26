import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_skeleton_list.dart';
import '../../../../core/widgets/loading/skeletons/subject_card_skeleton.dart';

/// First-paint state for the subjects tab. Padding and gap are `SubjectsList`'s.
class SubjectsSkeleton extends StatelessWidget {
  const SubjectsSkeleton({super.key, this.itemCount = 6});

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
      itemBuilder: (BuildContext context) => const SubjectCardSkeleton(),
    );
  }
}
