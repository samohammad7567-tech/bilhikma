import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeletons/section_header_skeleton.dart';
import '../../../../core/widgets/loading/skeletons/subject_card_skeleton.dart';
import 'home_header_skeleton.dart';

/// First-paint state for the home tab. Mirrors `HomeSections` down to its
/// paddings, so the real content lands without a shift.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key, this.subjectCount = 3});

  final int subjectCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppBottomNavBar.barHeight + 18.h),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const InstitutionCardSkeleton(),

                SizedBox(height: 14.h),

                const HomeStatsRowSkeleton(),

                SizedBox(height: 20.h),

                const SectionHeaderSkeleton(hasSubtitle: true, hasAction: true),

                SizedBox(height: 12.h),
              ],
            ),
          ),

          for (int index = 0; index < subjectCount; index++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: const SubjectCardSkeleton(),
            ),
        ],
      ),
    );
  }
}
