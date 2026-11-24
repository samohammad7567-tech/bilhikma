import 'package:flutter/material.dart';

import 'info_item.dart';
import 'info_title.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({required this.items, super.key});

  final List<InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular((8).r(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (InfoItem item) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: (4).h(context)),
                      child: InfoTile(item: item),
                    ),

                    if (item != items.last) ...<Widget>[
                      Divider(
                        height: (1).h(context),
                        thickness: 1,
                        color: colors.onSurface.withValues(alpha: 0.09),
                      ),
                    ],
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
