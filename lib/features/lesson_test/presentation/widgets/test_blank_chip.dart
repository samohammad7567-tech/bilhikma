import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestBlankChip extends StatelessWidget {
  const TestBlankChip({
    required this.value,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String? value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? value = this.value;

    if (value == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular((6).r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: (4).w(context), vertical: (2).h(context)),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.tertiaryContainer.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular((6).r(context)),
          ),
          child: Text('__________', style: AppTheme.styles(context).bodyMedium),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular((8).r(context)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: (10).w(context), vertical: (6).h(context)),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular((8).r(context)),
          border: isSelected
              ? Border.all(color: colors.secondary, width: 1.4.w(context))
              : null,
        ),
        child: Text(
          value,
          style: AppTheme.styles(
            context,
          ).labelStrong.copyWith(decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
