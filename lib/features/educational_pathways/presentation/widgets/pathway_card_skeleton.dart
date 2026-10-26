import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';

/// Mirrors `ActivePathwayCard` and `PathwayCard` — both are a 14.r card of
/// `PathwayInfoRow`s, the second one followed by the collapsed tree.
class PathwayCardSkeleton extends StatelessWidget {
  const PathwayCardSkeleton({
    super.key,
    this.treeRows = 0,
    this.isActive = false,
  });

  /// Collapsed tree rows to stand in for, as `PathwayTree` renders them.
  final int treeRows;

  /// The active card sits on the ornamented surface; the list cards do not.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color surface = isActive
        ? colors.tertiaryContainer
        : colors.surfaceContainerHighest;

    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _InfoRowSkeleton(surface: surface, valueWidth: 150.w),

            SizedBox(height: 14.h),

            _InfoRowSkeleton(
              surface: surface,
              valueWidth: isActive ? 120.w : null,
            ),

            if (treeRows > 0) ...<Widget>[
              SizedBox(height: 8.h),

              for (int index = 0; index < treeRows; index++)
                _NodeRowSkeleton(surface: surface),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton({required this.surface, this.valueWidth});

  final Color surface;
  final double? valueWidth;

  @override
  Widget build(BuildContext context) {
    final double? valueWidth = this.valueWidth;

    return Row(
      children: <Widget>[
        // Icon tile: a 24.w glyph inside 8px padding on every side.
        SkeletonBox(
          height: 24.w + 16,
          width: 24.w + 16,
          radius: 8.r,
          surface: surface,
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SkeletonTextLine(fontSize: 12.sp, width: 96.w, surface: surface),

              if (valueWidth != null)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: SkeletonTextLine(
                    fontSize: 14.sp,
                    width: valueWidth,
                    surface: surface,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeRowSkeleton extends StatelessWidget {
  const _NodeRowSkeleton({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(40.w, 8.h, 12.w, 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SkeletonTextLine(fontSize: 14.sp, width: 130.w, surface: surface),

          SizedBox(width: 6.w),

          SkeletonBox(height: 20.w, width: 20.w, radius: 4.r, surface: surface),
        ],
      ),
    );
  }
}
