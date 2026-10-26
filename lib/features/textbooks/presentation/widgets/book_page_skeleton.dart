import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/loading/app_shimmer.dart';
import '../../../../core/widgets/loading/skeleton_text_line.dart';

/// Stands in for the first PDF page while the document opens — the slowest
/// asset in the app, and until now the only screen with no loading state at
/// all. Sits over the live viewer, so nothing is torn down to show it.
class BookPageSkeleton extends StatelessWidget {
  const BookPageSkeleton({super.key});

  /// Line widths repeat over this run, so the block reads as prose.
  static const List<double> _widthFactors = <double>[
    1,
    0.96,
    0.92,
    1,
    0.88,
    0.97,
    0.93,
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: AspectRatio(
            aspectRatio: 1 / 1.414,
            child: AppShimmer(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
                child: _Lines(surface: colors.surfaceContainerLowest),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.surface});

  final Color surface;

  @override
  Widget build(BuildContext context) {
    final double gap = 10.h;
    final double lineBox = 12.sp * 1.5 + gap;
    final double headingBox = 17.sp * 1.5 + 18.h;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Fill whatever page height this device gives us, never overflow it.
        final int count = constraints.maxHeight.isFinite
            ? ((constraints.maxHeight - headingBox) / lineBox).floor().clamp(
                0,
                40,
              )
            : 12;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SkeletonTextLine(
              fontSize: 17.sp,
              widthFactor: 0.55,
              surface: surface,
            ),

            SizedBox(height: 18.h),

            for (int index = 0; index < count; index++) ...<Widget>[
              SkeletonTextLine(
                fontSize: 12.sp,
                widthFactor:
                    BookPageSkeleton._widthFactors[index %
                        BookPageSkeleton._widthFactors.length],
                surface: surface,
              ),

              SizedBox(height: gap),
            ],
          ],
        );
      },
    );
  }
}
