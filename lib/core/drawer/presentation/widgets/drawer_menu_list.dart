import 'package:flutter/material.dart';

import '../../../enums/drawer_destination_enum.dart';
import 'drawer_menu_item.dart';

class DrawerMenuList extends StatelessWidget {
  const DrawerMenuList({required this.onDestinationTap, super.key});

  final ValueChanged<DrawerDestination> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final DrawerDestination destination
            in DrawerDestination.values) ...<Widget>[
          if (_startsNewGroup(destination))
            Divider(
              height: 24,
              thickness: 1,
              indent: 12,
              endIndent: 12,
              color: colors.outline.withValues(alpha: 0.25),
            ),

          DrawerMenuItem(
            destination: destination,
            onTap: () => onDestinationTap(destination),
          ),
        ],
      ],
    );
  }

  static bool _startsNewGroup(DrawerDestination destination) {
    final int index = destination.index;
    if (index == 0) return false;

    return DrawerDestination.values[index - 1].group != destination.group;
  }
}
