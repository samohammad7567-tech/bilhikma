import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The "10s" flash shown on the half of the surface that was double tapped.
class LessonVideoRewindHint extends StatelessWidget {
  const LessonVideoRewindHint({
    required this.visible,
    this.isForward = false,
    super.key,
  });

  final bool visible;

  final bool isForward;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: visible ? 0.25 : 0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isForward
                    ? Icons.fast_forward_rounded
                    : Icons.fast_rewind_rounded,
                color: Colors.white,
                size: 30.sp,
              ),
              Text(
                '10s',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
