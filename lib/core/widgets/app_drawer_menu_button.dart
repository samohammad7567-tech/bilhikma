import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';
import 'app_icon.dart';
import 'custom_bar_icon.dart';

/// The hamburger that opens the app drawer.
///
/// Every shell tab shows one in the same corner, so it lives here rather than
/// in any one feature. [AppSectionScaffold] places it in its start slot — right
/// in Arabic, left in English — which is why nothing here mentions a side.
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
