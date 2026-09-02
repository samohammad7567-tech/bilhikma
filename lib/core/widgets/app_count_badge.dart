import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'count_badge_bubble.dart';

class AppCountBadge extends StatelessWidget {
  const AppCountBadge({
    required this.count,
    required this.child,
    super.key,
    this.max = 99,
  });

  final int count;
  final int max;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final String label = count > max ? '$max+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        child,

        PositionedDirectional(
          top: -2.h,
          end: -2.w,
          child: CountBadgeBubble(label: label),
        ),
      ],
    );
  }
}
