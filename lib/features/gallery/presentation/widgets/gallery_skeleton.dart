import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';
import 'gallery_grid.dart';

/// First-paint state for the album grid. Uses `GalleryGrid`'s own column count
/// and spacing, so the tiles land exactly where the placeholders were.
class GallerySkeleton extends StatelessWidget {
  const GallerySkeleton({super.key, this.itemCount = 9});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GalleryGrid.columnsFor(context),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
        ),
        itemBuilder: (BuildContext context, int index) =>
            AppShimmer(child: SkeletonBox(radius: 8.r)),
      ),
    );
  }
}
