import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonVideoRoundButton extends StatelessWidget {
  const LessonVideoRoundButton({
    required this.icon,
    required this.size,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
