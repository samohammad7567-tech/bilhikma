import '../../../../core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_count_badge.dart';
import '../../../../core/widgets/brand_badge.dart';
import '../../../../core/widgets/custom_bar_icon.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    this.onMenuTap,
    this.onNotificationsTap,
    this.unreadNotifications = 0,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CustomBarIcon(
          onTap: onMenuTap,
          padding: 13.w,
          child: AppIcon(
            asset: AppAssets.assetsMenuIcon,
            size: 20,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),

        BrandBadge(size: 68.w),

        AppCountBadge(
          count: unreadNotifications,
          child: CustomBarIcon(
            onTap: onNotificationsTap,
            child: Image.asset(
              AppAssets.assetsNotificationIcon,
              fit: BoxFit.contain,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}
