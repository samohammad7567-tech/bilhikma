import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_icon.dart';

class AppDialogGlyph extends StatelessWidget {
  const AppDialogGlyph({
    required this.imagePath,
    super.key,
    this.backgroundColor,
    this.iconColor,
  });

  final String imagePath;

  final Color? backgroundColor;

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.error.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: AppIcon(
          asset: imagePath,
          size: 20.w,
          color: iconColor ?? colors.onError,
        ),
      ),
    );
  }
}
