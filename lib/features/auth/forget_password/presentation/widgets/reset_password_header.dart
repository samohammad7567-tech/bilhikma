import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/themes/app_theme.dart';

class ResetPasswordHeader extends StatelessWidget {
  const ResetPasswordHeader({
    required this.headingKey,
    required this.hintKey,
    super.key,
  });

  final String headingKey;
  final String hintKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          AppAssets.assetsLogoText,
          height: 78.h,
          fit: BoxFit.contain,
        ),

        SizedBox(height: 18.h),

        Text(
          headingKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).sectionTitle,
        ),

        SizedBox(height: 8.h),

        Text(
          hintKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardSubtitle,
        ),
      ],
    );
  }
}
