import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';

/// Mirrors `LessonMediaTabs` — the segmented row above a lesson list.
class MediaTabsSkeleton extends StatelessWidget {
  const MediaTabsSkeleton({super.key, this.tabCount = 3});

  final int tabCount;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.tertiaryContainer;

    return AppShimmer(
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < tabCount; i++) ...<Widget>[
              if (i > 0) SizedBox(width: 8.w),

              Expanded(
                child: SkeletonBox(height: 38.h, radius: 8.r, surface: surface),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
