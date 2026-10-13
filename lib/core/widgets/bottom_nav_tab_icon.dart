import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/app_tab_enum.dart';
import 'app_icon.dart';

class BottomNavTabIcon extends StatelessWidget {
  const BottomNavTabIcon({
    required this.tab,
    required this.isSelected,
    super.key,
  });
  static const double iconSize = 24;
  static const double selectedDiameter = 48;
  static const double haloDiameter = 60;

  final AppTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget icon = AppIcon(
      asset: tab.icon,
      size: iconSize.w,
      color: isSelected ? colors.tertiaryContainer : colors.onSecondary,
    );

    if (!isSelected) return icon;

    return Container(
      width: haloDiameter.w,
      height: haloDiameter.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: Container(
        width: selectedDiameter.w,
        height: selectedDiameter.w,
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
