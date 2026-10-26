import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../skeleton_box.dart';
import '../skeleton_text_line.dart';

/// Mirrors `AppProgressBar`: the percentage label aligned to the end, then the
/// 6.h track.
class ProgressBarSkeleton extends StatelessWidget {
  const ProgressBarSkeleton({super.key, this.surface, this.showPercent = true});

  final Color? surface;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showPercent) ...<Widget>[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SkeletonTextLine(
              fontSize: 11.sp,
              width: 30.w,
              surface: surface,
            ),
          ),

          SizedBox(height: 4.h),
        ],

        SkeletonBox(height: 6.h, radius: 6.h, surface: surface),
      ],
    );
  }
}
