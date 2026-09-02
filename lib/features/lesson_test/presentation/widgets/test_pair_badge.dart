import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';

class TestPairBadge extends StatelessWidget {
  const TestPairBadge({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double diameter = 20.w;

    return Container(
      constraints: BoxConstraints(minWidth: diameter, minHeight: diameter),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondary,

        borderRadius: BorderRadius.circular(diameter),
      ),
      child: Text(
        '$value',
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).badgeLabel.copyWith(color: colors.onSecondary),
      ),
    );
  }
}
