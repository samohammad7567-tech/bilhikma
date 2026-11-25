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

  static const Duration _animationDuration = Duration(milliseconds: 220);

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Duration duration = reduceMotion ? Duration.zero : _animationDuration;
    final Curve curve = reduceMotion ? Curves.linear : Curves.easeOutCubic;
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
          onDestinationSelected: (int index) {
            onTabSelected(AppTab.values[index]);
          },
          labelType: NavigationRailLabelType.all,
          useIndicator: true,
          indicatorColor: colors.tertiary.withValues(alpha: 0.18),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          destinations: <NavigationRailDestination>[
            for (final AppTab tab in AppTab.values)
              _destination(
                tab: tab,
                selected: tab == selectedTab,
                colors: colors,
                labelStyle: labelStyle,
                duration: duration,
                curve: curve,
              ),
          ],
        ),
      ),
    );
  }

  NavigationRailDestination _destination({
    required AppTab tab,
    required bool selected,
    required ColorScheme colors,
    required TextStyle labelStyle,
    required Duration duration,
    required Curve curve,
  }) {
    final Widget icon = _AnimatedRailIcon(
      key: ValueKey<AppTab>(tab),
      tab: tab,
      selected: selected,
      duration: duration,
      curve: curve,
    );

    return NavigationRailDestination(
      icon: icon,
      selectedIcon: icon,
      label: AnimatedDefaultTextStyle(
        duration: duration,
        curve: curve,
        style: labelStyle.copyWith(
          color: selected
              ? colors.tertiary
              : colors.onSecondary.withValues(alpha: 0.72),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        child: Text(
          tab.label.tr(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AnimatedRailIcon extends StatefulWidget {
  const _AnimatedRailIcon({
    required this.tab,
    required this.selected,
    required this.duration,
    required this.curve,
    super.key,
  });

  final AppTab tab;
  final bool selected;
  final Duration duration;
  final Curve curve;

  @override
  State<_AnimatedRailIcon> createState() => _AnimatedRailIconState();
}

class _AnimatedRailIconState extends State<_AnimatedRailIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.94 : (widget.selected ? 1 : 0.9);

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: widget.duration,
        curve: widget.curve,
        opacity: widget.selected ? 1 : 0.86,
        child: AnimatedScale(
          duration: widget.duration,
          curve: widget.curve,
          scale: scale,
          child: BottomNavTabIcon(tab: widget.tab, isSelected: widget.selected),
        ),
      ),
    );
  }
}
 