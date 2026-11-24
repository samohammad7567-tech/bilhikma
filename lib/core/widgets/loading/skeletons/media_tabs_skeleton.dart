import 'package:bilhikma/core/widgets/loading/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class MediaTabsSkeleton extends StatelessWidget {
  const MediaTabsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (12).h(context)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SkeletonBox(height: (36).h(context), radius: 8),
              ),
              SizedBox(width: (8).w(context)),
              Expanded(
                child: SkeletonBox(height: (36).h(context), radius: 8),
              ),
            ],
          ),
          SizedBox(height: (16).h(context)),
          ...List<Widget>.generate(
            4,
            (int index) => Padding(
              padding: EdgeInsets.only(bottom: (12).h(context)),
              child: SkeletonBox(height: (80).h(context), radius: 12),
            ),
          ),
        ],
      ),
    );
  }
}
