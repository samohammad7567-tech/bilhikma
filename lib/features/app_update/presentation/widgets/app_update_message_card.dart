import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';

class AppUpdateMessageCard extends StatelessWidget {
  const AppUpdateMessageCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7),
      ),
    );
  }
}
