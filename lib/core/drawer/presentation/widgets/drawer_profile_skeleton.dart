import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/loading/app_shimmer.dart';
import '../../../widgets/loading/skeleton_box.dart';
import '../../../widgets/loading/skeleton_text_line.dart';

/// The drawer's identity row before the profile arrives. Until now this was a
/// blank underlined text slot on every drawer open.
class DrawerProfileSkeleton extends StatelessWidget {
  const DrawerProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.tertiaryContainer;

    return AppShimmer(
      child: Row(
        children: <Widget>[
          SkeletonBox(
            height: 52.w,
            width: 52.w,
            isCircular: true,
            surface: surface,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: SkeletonTextLine(
              fontSize: 15.sp,
              widthFactor: 0.7,
              surface: surface,
            ),
          ),
        ],
      ),
    );
  }
}
