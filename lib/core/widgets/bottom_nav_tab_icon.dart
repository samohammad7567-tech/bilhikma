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

  final AppTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget icon = AppIcon(
      asset: tab.icon,
      size: 24.w,
      color: isSelected ? colors.tertiaryContainer : colors.onSecondary,
    );

    if (!isSelected) return icon;

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: colors.secondary,
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }
}
