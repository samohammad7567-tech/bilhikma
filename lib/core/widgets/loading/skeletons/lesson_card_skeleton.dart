import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';
import '../skeleton_text_line.dart';

/// Mirrors `LessonCard`: the 104.w thumbnail, the title/badge row, the
/// description line and the meta row underneath.
class LessonCardSkeleton extends StatelessWidget {
  const LessonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.tertiaryContainer;

    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SkeletonBox(width: 104.w, radius: 10.r, surface: surface),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: SkeletonTextLine(
                              fontSize: 15.sp,
                              widthFactor: 0.85,
                              surface: surface,
                            ),
                          ),

                          SizedBox(width: 8.w),

                          SkeletonBox(
                            height: 20.h,
                            width: 46.w,
                            radius: 20.r,
                            surface: surface,
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      SkeletonTextLine(
                        fontSize: 12.sp,
                        widthFactor: 0.6,
                        surface: surface,
                      ),

                      SizedBox(height: 10.h),

                      Row(
                        children: <Widget>[
                          SkeletonTextLine(
                            fontSize: 12.sp,
                            width: 74.w,
                            surface: surface,
                          ),

                          SizedBox(width: 14.w),

                          SkeletonTextLine(
                            fontSize: 12.sp,
                            width: 56.w,
                            surface: surface,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
