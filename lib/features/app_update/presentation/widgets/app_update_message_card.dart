import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppUpdateMessageCard extends StatelessWidget {
  const AppUpdateMessageCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: (16).w(context), vertical: (14).h(context)),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular((14).r(context)),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7.h(context)),
      ),
    );
  }
}
