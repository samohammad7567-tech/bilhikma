import 'package:flutter/material.dart';

import 'pathway_icon_tile.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class PathwayInfoRow extends StatelessWidget {
  const PathwayInfoRow({
    required this.asset,
    required this.label,
    super.key,
    this.values = const [],
  });

  final String asset;
  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PathwayIconTile(asset: asset),
        SizedBox(width: (10).w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowValue.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.55),
                ),
              ),
              for (final String value in values)
                Padding(
                  padding: EdgeInsets.only(top: (2).h(context)),
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.styles(
                      context,
                    ).rowTitle.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
