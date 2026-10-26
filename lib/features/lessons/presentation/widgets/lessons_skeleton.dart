import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeletons/lesson_cards_skeleton.dart';
import '../../../../core/widgets/loading/skeletons/lesson_subject_header_skeleton.dart';
import '../../../../core/widgets/loading/skeletons/media_tabs_skeleton.dart';

/// First-paint state for the lessons screen: subject header, media tabs, then
/// lesson cards — the same order and spacing as `LessonsContent`.
class LessonsSkeleton extends StatelessWidget {
  const LessonsSkeleton({super.key, this.itemCount = 3});

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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: MediaTabsSkeleton(tabCount: ContentType.values.length),
          ),

          SizedBox(height: 16.h),

          LessonCardsSkeleton(itemCount: itemCount),
        ],
      ),
    );
  }
}
