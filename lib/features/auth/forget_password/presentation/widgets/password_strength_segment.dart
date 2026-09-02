import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      height: 5.h,
      decoration: BoxDecoration(
        color: isFilled ? tone : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
