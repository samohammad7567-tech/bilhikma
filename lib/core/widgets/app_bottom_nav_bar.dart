import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../enums/app_tab_enum.dart';
import '../themes/app_theme.dart';
import 'bottom_nav_tab_icon.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  static double get barHeight => 70.h;

  static const double _maxLabelTextScale = 1;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle labelStyle = AppTheme.styles(context).navLabel;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxLabelTextScale,

      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        child: CurvedNavigationBar(
          index: selectedTab.index,
          onTap: (int index) => onTabSelected(AppTab.values[index]),
          color: colors.secondary,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: colors.surface,
          iconPadding: 3.w,
          height: barHeight,
          animationDuration: const Duration(milliseconds: 400),
          items: <CurvedNavigationBarItem>[
            for (final AppTab tab in AppTab.values)
              CurvedNavigationBarItem(
                child: BottomNavTabIcon(
                  tab: tab,
                  isSelected: tab == selectedTab,
                ),
                label: tab.label.tr(),
                labelStyle: tab == selectedTab
                    ? labelStyle.copyWith(color: colors.tertiaryContainer)
                    : labelStyle,
              ),
          ],
        ),
      ),
    );
  }
}
