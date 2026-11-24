import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SettingsGlyphTile extends StatelessWidget {
  const SettingsGlyphTile({
    required this.imagePath,
    super.key,
    this.backgroundColor,
    this.iconColor,
  });

  final String imagePath;

  final Color? backgroundColor;

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: (38).w(context),
      height: (38).h(context),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular((10).r(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all((8).r(context)),
        child: AppIcon(asset: imagePath, size: (20).r(context), color: iconColor),
      ),
    );
  }
}
