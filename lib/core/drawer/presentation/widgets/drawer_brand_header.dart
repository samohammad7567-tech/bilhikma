import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_assets.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/app_icon.dart';
import '../../../widgets/ornamented_card.dart';

class DrawerBrandHeader extends StatelessWidget {
  const DrawerBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: OrnamentedCard(
              color: Theme.of(context).colorScheme.primary,
              child: Column(children: []),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(80.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: AppIcon(
                    asset: AppAssets.assetsLogoText,
                    color: Theme.of(context).colorScheme.tertiary,
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  'platform_tagline'.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(
                    context,
                  ).brandTagline.copyWith(color: colors.tertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
