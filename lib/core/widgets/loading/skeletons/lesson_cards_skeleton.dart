import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_shimmer.dart';
import 'lesson_card_skeleton.dart';

/// A non-scrolling run of lesson-card skeletons, for use inside a list that
/// already scrolls — a category or tab switch, where collapsing the list to a
/// centred spinner would jump the scroll position.
class LessonCardsSkeleton extends StatelessWidget {
  const LessonCardsSkeleton({super.key, this.itemCount = 3, this.padding});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding =
        this.padding ?? EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h);

    return AppShimmerGroup(
      child: Column(
        children: <Widget>[
          for (int index = 0; index < itemCount; index++)
            Padding(padding: padding, child: const LessonCardSkeleton()),
        ],
      ),
    );
  }
}
