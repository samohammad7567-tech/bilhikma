import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class PasswordStrengthSegment extends StatelessWidget {
  const PasswordStrengthSegment({
    required this.isFilled,
    required this.tone,
    super.key,
  });

  final bool isFilled;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: (5).h(context),
      decoration: BoxDecoration(
        color: isFilled ? tone : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular((4).r(context)),
      ),
    );
  }
}
