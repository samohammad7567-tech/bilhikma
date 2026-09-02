import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTileTrailing extends StatelessWidget {
  const SettingsTileTrailing({required this.isBusy, super.key});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isBusy) {
      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          color: colors.secondary,
        ),
      );
    }

    return Icon(
      Icons.arrow_forward_ios,
      size: 14.w,
      color: colors.onSurfaceVariant,
    );
  }
}
