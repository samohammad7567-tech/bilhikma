import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../enums/app_tab_enum.dart';
import '../themes/app_theme.dart';
import '../utils/my_screen_size.dart';
import 'bottom_nav_tab_icon.dart';

class AppNavRail extends StatelessWidget {
  const AppNavRail({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  static const double width = 96;
  static const double _labelFontSize = 12;
  static const double _maxLabelTextScale = 1;

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle labelStyle = AppTheme.styles(
      context,
    ).navLabel.copyWith(fontSize: _labelFontSize);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxLabelTextScale,
      child: SizedBox(
        width: MyScreenSize.navRailWidth(context),
        child: NavigationRail(
          backgroundColor: colors.secondary,
          selectedIndex: selectedTab.index,
          onDestinationSelected: (int index) =>
              onTabSelected(AppTab.values[index]),
          labelType: NavigationRailLabelType.all,
          destinations: <NavigationRailDestination>[
            for (final AppTab tab in AppTab.values)
              NavigationRailDestination(
                icon: BottomNavTabIcon(tab: tab, isSelected: false),
                selectedIcon: BottomNavTabIcon(tab: tab, isSelected: true),
                label: Text(
                  tab.label.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
