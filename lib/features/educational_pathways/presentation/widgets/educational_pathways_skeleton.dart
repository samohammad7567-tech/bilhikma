import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';
import 'pathway_card_skeleton.dart';

/// First-paint state for the educational-pathways screen: the active pathway
/// card, then the list of pathways — `EducationalPathwaysContent`'s rhythm.
class EducationalPathwaysSkeleton extends StatelessWidget {
  const EducationalPathwaysSkeleton({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: <Widget>[
          _TitleSkeleton(width: 150.w),

          SizedBox(height: 12.h),

          const PathwayCardSkeleton(isActive: true),

          SizedBox(height: 24.h),

          _TitleSkeleton(width: 120.w),

          SizedBox(height: 12.h),

          for (int index = 0; index < itemCount; index++) ...<Widget>[
            const PathwayCardSkeleton(treeRows: 2),

            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }
}

class _TitleSkeleton extends StatelessWidget {
  const _TitleSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SkeletonTextLine(fontSize: 18.sp, width: width),
  );
}
