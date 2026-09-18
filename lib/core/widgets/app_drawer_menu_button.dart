import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';
import 'app_icon.dart';
import 'custom_bar_icon.dart';

class AppDrawerMenuButton extends StatelessWidget {
  const AppDrawerMenuButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomBarIcon(
      onTap: onTap,
      padding: 13.w,
      child: AppIcon(
        asset: AppAssets.assetsMenuIcon,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
