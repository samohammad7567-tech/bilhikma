import 'app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';

class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double diameter = size ?? 56.w;

    return Container(
      width: diameter,
      height: diameter,
      padding: EdgeInsets.all(diameter * 0.24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: AppIcon(
        asset: AppAssets.assetsLogoText,
        fit: BoxFit.contain,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
