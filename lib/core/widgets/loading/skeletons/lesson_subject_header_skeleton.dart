import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';
import '../skeleton_text_line.dart';
import 'progress_bar_skeleton.dart';

/// Mirrors `LessonSubjectHeader`: index strip, 64.w brand badge, subject name
/// and the progress bar.
class LessonSubjectHeaderSkeleton extends StatelessWidget {
  const LessonSubjectHeaderSkeleton({super.key});

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
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: <Widget>[
                      SkeletonBox(
                        height: 64.w,
                        width: 64.w,
                        isCircular: true,
                        surface: surface,
                      ),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SkeletonTextLine(
                              fontSize: 17.sp,
                              widthFactor: 0.65,
                              surface: surface,
                            ),

                            SizedBox(height: 14.h),

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
