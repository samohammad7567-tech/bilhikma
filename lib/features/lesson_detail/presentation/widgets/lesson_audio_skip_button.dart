import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonAudioSkipButton extends StatelessWidget {
  const LessonAudioSkipButton({required this.icon, super.key, this.onTap});

  final IconData icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour = Theme.of(context).colorScheme.secondaryContainer;

    return InkResponse(
      onTap: onTap,
      radius: 24.w,
      child: Icon(
        icon,
        size: 28.w,
        color: onTap == null ? colour.withValues(alpha: 0.4) : colour,
      ),
    );
  }
}
