import 'package:bilhikma/core/widgets/loading/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (12).h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonBox(height: (40).h(context), width: (40).w(context), isCircular: true),
          SizedBox(width: (12).w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: (16).h(context), width: double.infinity),
                SizedBox(height: (8).h(context)),
                SkeletonBox(height: (12).h(context), width: (200).w(context)),
                SizedBox(height: (6).h(context)),
                SkeletonBox(height: (10).h(context), width: (120).w(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
