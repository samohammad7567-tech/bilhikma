import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';

/// Mirrors `LessonCategoryChips` — the 44.h horizontal strip of pills. The
/// widths vary the way real labels do, so the strip does not read as a grid.
class CategoryChipsSkeleton extends StatelessWidget {
  const CategoryChipsSkeleton({super.key});

  static const List<double> _widths = <double>[104, 86, 96, 110];

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 44.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: _widths.length,
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(width: 10.w),
          itemBuilder: (BuildContext context, int index) => SkeletonBox(
            height: 44.h,
            width: _widths[index].w,
            radius: 44.h / 2,
          ),
        ),
      ),
    );
  }
}
