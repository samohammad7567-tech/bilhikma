import 'package:flutter/material.dart';

import '../enums/app_tab_enum.dart';
import '../utils/my_screen_size.dart';
import 'app_icon.dart';

class BottomNavTabIcon extends StatelessWidget {
  const BottomNavTabIcon({
    required this.tab,
    required this.isSelected,
    super.key,
  });

  final AppTab tab;
  final bool isSelected;

  // Max clamp values — all test screen widths (390–1180 px) exceed the
  // thresholds where the responsive fractions would fall below the max,
  // so the rendered size always equals these constants.
  static const double iconSize = 24.0;      // (w * 0.075).clamp(16, 24)
  static const double haloDiameter = 44.0; // (w * 0.15).clamp(34, 44)

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final double computedIconSize = MyScreenSize.widthFraction(
      context,
      0.075,
      min: 16,
      max: 24,
    );
    final double selectedDiameter = MyScreenSize.widthFraction(
      context,
      0.13,
      min: 30,
      max: 40,
    );
    final double computedHaloDiameter = MyScreenSize.widthFraction(
      context,
      0.15,
      min: 34,
      max: 44,
    );

    final icon = AppIcon(
      asset: tab.icon,
      size: computedIconSize,
      color: isSelected ? colors.tertiaryContainer : colors.onSecondary,
    );

    if (!isSelected) return icon;

    return Container(
      width: computedHaloDiameter,
      height: computedHaloDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: Container(
        width: selectedDiameter,
        height: selectedDiameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.secondary,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}
