import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import 'splash_fade_up.dart';

class SplashBrandTexts extends StatelessWidget {
  const SplashBrandTexts({
    super.key,
    required this.titleEntry,
    required this.taglineEntry,
  });
  final Animation<double> titleEntry;
  final Animation<double> taglineEntry;

  @override
  Widget build(BuildContext context) {
    final Color brandColor = Theme.of(context).primaryColorDark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SplashFadeUp(
            entry: titleEntry,
            child: Text(
              'platform_name'.tr(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(
                context,
              ).splashTitle.copyWith(color: brandColor),
            ),
          ),
          SizedBox(height: 12.h),
          SplashFadeUp(
            entry: taglineEntry,
            child: Text(
              'platform_tagline'.tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(
                context,
              ).bodyLarge.copyWith(color: brandColor),
            ),
          ),
        ],
      ),
    );
  }
}
