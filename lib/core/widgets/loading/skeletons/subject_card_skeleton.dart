import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';
import '../skeleton_text_line.dart';
import 'progress_bar_skeleton.dart';

/// Mirrors `SubjectCard`: index strip, brand badge, title, subtitle, progress.
/// Every size is copied from the real card so nothing shifts on arrival.
class SubjectCardSkeleton extends StatelessWidget {
  const SubjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color surface = colors.tertiaryContainer;

    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The real `IndexStrip` is an opaque band with the order on top.
              Container(
                width: 26.w,
                color: colors.tertiary,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 10.h),
                child: SkeletonBox(
                  height: 11.sp,
                  width: 10.w,
                  radius: 3.r,
                  surface: colors.tertiary,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: <Widget>[
                      SkeletonBox(
                        height: 58.w,
                        width: 58.w,
                        isCircular: true,
                        surface: surface,
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SkeletonTextLine(
                              fontSize: 15.sp,
                              widthFactor: 0.7,
                              surface: surface,
                            ),

                            SizedBox(height: 2.h),

                            SkeletonTextLine(
                              fontSize: 12.sp,
                              widthFactor: 0.4,
                              surface: surface,
                            ),

                            SizedBox(height: 10.h),

                            ProgressBarSkeleton(surface: surface),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
