import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../enums/app_tab_enum.dart';
import '../themes/app_theme.dart';
import '../utils/my_screen_size.dart';
import 'bottom_nav_tab_icon.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  static const double _minBarHeight = 60;
  static const double _maxBarHeight = 80;

  static const double _labelFontSize = 12;
  static const double _extraHeightPerScale = 20;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // System accessibility text scaling.
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    // Actual scaled label font size.
    final double scaledLabelSize = textScaler.scale(_labelFontSize);

    // Calculate additional height according to text scaling.
    final double additionalHeight =
        (scaledLabelSize - _labelFontSize) *
        (_extraHeightPerScale / _labelFontSize);

    final double barHeight =
        (MyScreenSize.bottomChromeHeight(context) + additionalHeight).clamp(
          _minBarHeight,
          _maxBarHeight,
        );

    final TextStyle labelStyle = AppTheme.styles(
      context,
    ).navLabel.copyWith(fontSize: _labelFontSize);

    return DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      child: CurvedNavigationBar(
        index: selectedTab.index,
        onTap: (int index) {
          onTabSelected(AppTab.values[index]);
        },
        color: colors.secondary,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.transparent,
        iconPadding: 0,
        height: barHeight,
        animationDuration: const Duration(milliseconds: 400),
        items: <CurvedNavigationBarItem>[
          for (final AppTab tab in AppTab.values)
            CurvedNavigationBarItem(
              child: BottomNavTabIcon(tab: tab, isSelected: tab == selectedTab),
              label: tab.label.tr(),
              labelStyle: tab == selectedTab
                  ? labelStyle.copyWith(color: colors.tertiaryContainer)
                  : labelStyle,
            ),
        ],
      ),
    );
  }
}
