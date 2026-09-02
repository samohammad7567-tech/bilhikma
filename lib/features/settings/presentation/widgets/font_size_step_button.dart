import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontSizeStepButton extends StatelessWidget {
  const FontSizeStepButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;

    return Material(
      color: colors.tertiary.withValues(alpha: isEnabled ? 0.8 : 0.32),
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44.w,
          height: 40.h,
          child: Icon(
            icon,
            size: 22.w,
            color: colors.secondaryContainer.withValues(
              alpha: isEnabled ? 1 : 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
