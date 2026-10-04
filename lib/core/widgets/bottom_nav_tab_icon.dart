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

  /// Box every tab glyph is drawn into, selected or not.
  static const double iconSize = 24;

  /// Diameter of the filled circle directly behind the selected glyph.
  static const double selectedDiameter = 48;

  /// Diameter of the halo drawn around [selectedDiameter].
  ///
  /// Drawn here rather than left to the nav bar's `buttonBackgroundColor`, so
  /// it renders for whichever tab is selected instead of depending on how the
  /// package happens to size its floating button.
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
