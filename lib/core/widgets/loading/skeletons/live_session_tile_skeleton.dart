import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';
import '../skeleton_text_line.dart';

/// Mirrors `LiveSessionTile`: thumbnail, title, description, the date/time
/// meta row and the trailing action button.
class LiveSessionTileSkeleton extends StatelessWidget {
  const LiveSessionTileSkeleton({super.key});

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
                      SkeletonTextLine(
                        fontSize: 15.sp,
                        widthFactor: 0.8,
                        surface: surface,
                      ),

                      SizedBox(height: 4.h),

                      SkeletonTextLine(
                        fontSize: 13.sp,
                        widthFactor: 0.55,
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
                            width: 50.w,
                            surface: surface,
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: SkeletonBox(
                          height: 40.h,
                          width: 132.w,
                          radius: 8.r,
                          surface: surface,
                        ),
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
