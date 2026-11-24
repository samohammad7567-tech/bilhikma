import 'package:flutter/material.dart';

import '../../../../core/widgets/app_skeleton_box.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class DownloadsLogSkeleton extends StatelessWidget {
  const DownloadsLogSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB((16).w(context), (8).h(context), (16).w(context), (24).h(context)),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: (10).h(context)),
      itemBuilder: (BuildContext context, int index) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: (72).h(context),
      padding: EdgeInsets.symmetric(horizontal: (16).w(context)),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
      ),
      child: Row(
        children: <Widget>[
          AppSkeletonBox(height: (26).h(context), width: (26).w(context), radius: 6),

          SizedBox(width: (16).w(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppSkeletonBox(height: (12).h(context), width: (170).w(context)),

                SizedBox(height: (8).h(context)),

                AppSkeletonBox(height: (10).h(context), width: (60).w(context)),
              ],
            ),
          ),

          SizedBox(width: (12).w(context)),

          AppSkeletonBox(height: (22).h(context), width: (22).w(context), isCircular: true),
        ],
      ),
    );
  }
}
