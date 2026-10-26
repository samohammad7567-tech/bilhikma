import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeletons/category_chips_skeleton.dart';
import '../../../../core/widgets/loading/skeletons/lesson_cards_skeleton.dart';
import '../../../../core/widgets/loading/skeletons/lesson_subject_header_skeleton.dart';

/// First-paint state for the subject-content screen: subject header, category
/// chips, then the tiles of the default (lessons) category.
class SubjectContentSkeleton extends StatelessWidget {
  const SubjectContentSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const LessonSubjectHeaderSkeleton(),
          ),

          SizedBox(height: 16.h),

          const CategoryChipsSkeleton(),

          SizedBox(height: 16.h),

          LessonCardsSkeleton(itemCount: itemCount),
        ],
      ),
    );
  }
}
