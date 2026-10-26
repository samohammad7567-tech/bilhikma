import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';

/// Mirrors `InstitutionCard`: a centred banner title over the path line.
class InstitutionCardSkeleton extends StatelessWidget {
  const InstitutionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.tertiaryContainer;

    return AppShimmer(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SkeletonTextLine(fontSize: 17.sp, width: 190.w, surface: surface),

            SizedBox(height: 4.h),

            SkeletonTextLine(fontSize: 14.sp, width: 230.w, surface: surface),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `HomeStatsRow`: two stat tiles and the wider progress tile.
class HomeStatsRowSkeleton extends StatelessWidget {
  const HomeStatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AppShimmer(
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Expanded(child: _StatTileSkeleton()),

              SizedBox(width: 8.w),

              const Expanded(child: _StatTileSkeleton()),

              SizedBox(width: 8.w),

              Expanded(flex: 3, child: _ProgressTileSkeleton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTileSkeleton extends StatelessWidget {
  const _StatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SkeletonTextLine(fontSize: 16.sp, width: 24.w, surface: surface),

          SizedBox(height: 2.h),

          SkeletonTextLine(fontSize: 10.sp, width: 48.w, surface: surface),
        ],
      ),
    );
  }
}

class _ProgressTileSkeleton extends StatelessWidget {
  const _ProgressTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SkeletonTextLine(
                  fontSize: 13.sp,
                  widthFactor: 0.9,
                  surface: surface,
                ),

                SizedBox(height: 2.h),

                SkeletonTextLine(
                  fontSize: 10.sp,
                  widthFactor: 0.6,
                  surface: surface,
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          SkeletonBox(
            height: 46.w,
            width: 46.w,
            isCircular: true,
            surface: surface,
          ),
        ],
      ),
    );
  }
}
