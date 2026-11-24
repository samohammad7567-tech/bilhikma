import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class PathwayIconTile extends StatelessWidget {
  const PathwayIconTile({required this.asset, super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular((8).r(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0.r(context)),
        child: AppIcon(asset: asset, size: (24).r(context), color: colors.onPrimary),
      ),
    );
  }
}
