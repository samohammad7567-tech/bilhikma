import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonVideoRewindHint extends StatelessWidget {
  const LessonVideoRewindHint({required this.visible, super.key});

  final bool visible;

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
              Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 30.sp),
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
