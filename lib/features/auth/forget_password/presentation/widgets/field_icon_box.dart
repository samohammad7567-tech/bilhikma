import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_icon.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class FieldIconBox extends StatelessWidget {
  const FieldIconBox({required this.asset, super.key, this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget box = AppIcon(
      asset: asset,
      size: (17).r(context),
      color: colors.secondary,
      padding: EdgeInsets.all((12).r(context)),
    );

    if (onTap == null) return box;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}
