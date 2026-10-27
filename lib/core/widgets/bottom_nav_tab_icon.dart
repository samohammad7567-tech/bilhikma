import 'package:flutter/material.dart';

import '../enums/app_tab_enum.dart';
import 'app_icon.dart';

class BottomNavTabIcon extends StatelessWidget {
  const BottomNavTabIcon({
    required this.tab,
    required this.isSelected,
    super.key,
  });
  static const double iconSize = 24;
  static const double selectedDiameter = 44;
  static const double haloDiameter = 52;

  final AppTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget icon = AppIcon(
      asset: tab.icon,
      size: iconSize,
      color: isSelected ? colors.tertiaryContainer : colors.onSecondary,
    );

    if (!isSelected) return icon;

    return Container(
      width: haloDiameter,
      height: haloDiameter,
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
