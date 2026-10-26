import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/enums/profile_action_enum.dart';
import '../../../../core/enums/profile_field_enum.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_box.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';

/// First-paint state for the profile tab: avatar and name, the info card with
/// one row per `ProfileField`, then the action card.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerGroup(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          8.h,
          16.w,
          AppBottomNavBar.barHeight + 24.h,
        ),
        children: <Widget>[
          const _HeaderSkeleton(),

          SizedBox(height: 22.h),

          _CardSkeleton(
            color: AppColors.sandSoft,
            divider: AppColors.sand,
            indent: 16.w,
            rowCount: ProfileField.values.length,
            rowBuilder: (Color surface) => _InfoRowSkeleton(surface: surface),
          ),

          SizedBox(height: 14.h),

          _CardSkeleton(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
            divider: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
            indent: 12.w,
            rowCount: ProfileAction.values.length,
            rowBuilder: (Color surface) => _ActionRowSkeleton(surface: surface),
          ),
        ],
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SkeletonBox(height: 96.w, width: 96.w, isCircular: true),

          SizedBox(height: 14.h),

          SkeletonTextLine(fontSize: 18.sp, width: 160.w),
        ],
      ),
    );
  }
}

/// The two profile cards differ only in colour, indent and row shape.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({
    required this.color,
    required this.divider,
    required this.indent,
    required this.rowCount,
    required this.rowBuilder,
  });

  final Color color;
  final Color divider;
  final double indent;
  final int rowCount;
  final Widget Function(Color surface) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < rowCount; index++) ...<Widget>[
              if (index > 0)
                Divider(
                  height: 1.h,
                  thickness: 1.h,
                  indent: indent,
                  endIndent: indent,
                  color: divider,
                ),

              rowBuilder(color),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        children: <Widget>[
          SkeletonBox(height: 26.w, width: 26.w, radius: 6.r, surface: surface),

          SizedBox(width: 10.w),

          SkeletonTextLine(fontSize: 12.sp, width: 64.w, surface: surface),

          SizedBox(width: 12.w),

          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SkeletonTextLine(
                fontSize: 14.sp,
                width: 110.w,
                surface: surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRowSkeleton extends StatelessWidget {
  const _ActionRowSkeleton({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: <Widget>[
          SkeletonBox(
            height: 38.w,
            width: 38.w,
            radius: 10.r,
            surface: surface,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: SkeletonTextLine(
              fontSize: 14.sp,
              widthFactor: 0.5,
              surface: surface,
            ),
          ),

          SkeletonBox(height: 14.w, width: 14.w, radius: 3.r, surface: surface),
        ],
      ),
    );
  }
}
