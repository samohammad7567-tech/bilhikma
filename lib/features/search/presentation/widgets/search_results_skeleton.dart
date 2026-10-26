import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_skeleton_list.dart';
import '../../../../core/widgets/loading/skeletons/lesson_card_skeleton.dart';

/// Stands in for the result list while a query is in flight, so the list keeps
/// its height instead of collapsing to a centred spinner on every search.
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonList(
      itemCount: itemCount,
      gap: 12.h,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      itemBuilder: (BuildContext context) => const LessonCardSkeleton(),
    );
  }
}
