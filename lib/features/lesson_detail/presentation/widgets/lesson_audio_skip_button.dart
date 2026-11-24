import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonAudioSkipButton extends StatelessWidget {
  const LessonAudioSkipButton({required this.icon, super.key, this.onTap});

  final IconData icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour = Theme.of(context).colorScheme.secondaryContainer;

    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Icon(
        icon,
        size: (28).r(context),
        color: onTap == null ? colour.withValues(alpha: 0.4) : colour,
      ),
    );
  }
}
