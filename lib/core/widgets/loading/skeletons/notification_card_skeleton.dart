import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import '../skeleton_box.dart';

/// Mirrors `NotificationCard`: accent bar, kind tile, title row, body lines.
/// Sizes are copied from the real card so nothing shifts when content lands.
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  static const double _barWidth = 4;
  static const double _tileSize = 40;

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
        // The real card uses `IntrinsicHeight` so the accent bar can stretch
        // inside an unbounded list; mirrored here for the same reason.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: _barWidth.w,
                child: SkeletonBox(radius: 0, surface: surface),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 12.w, 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SkeletonBox(
                        height: _tileSize.w,
                        width: _tileSize.w,
                        radius: 10.r,
                        surface: surface,
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: SkeletonBox(
                                    height: 12.h,
                                    surface: surface,
                                  ),
                                ),

                                SizedBox(width: 8.w),

                                SkeletonBox(
                                  height: 16.h,
                                  width: 54.w,
                                  radius: 20.r,
                                  surface: surface,
                                ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            SkeletonBox(height: 10.h, surface: surface),

                            SizedBox(height: 6.h),

                            SkeletonBox(
                              height: 10.h,
                              width: 140.w,
                              surface: surface,
                            ),
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
