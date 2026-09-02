import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/custom_button.dart';

/// Shown when the detail endpoint answers 403 because the previous lesson in
/// the same subject is not completed yet. Retrying can never succeed, so this
/// offers a way back to the list instead of a retry button.
class LessonLockedView extends StatelessWidget {
  const LessonLockedView({required this.onBack, super.key, this.message});

  /// The localized `message` from the response body. Falls back to the bundled
  /// key only when the server did not send one.
  final String? message;

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);
    final String? message = this.message;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(
              asset: AppAssets.assetsLockIcon,
              size: 56.w,
              color: colors.secondary,
            ),

            SizedBox(height: 16.h),

            Text(
              'lesson_locked_title'.tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.cardTitle,
            ),

            SizedBox(height: 8.h),

            Text(
              message ?? 'lesson_locked_hint'.tr(),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: styles.bodyLarge.copyWith(color: colors.secondary),
            ),

            SizedBox(height: 24.h),

            CustomButton(
              onPressed: onBack,
              text: 'back_to_lessons'.tr(),
              width: double.infinity,
              height: 44.h,
              threeRadius: 8.r,
              lastRadius: 8.r,
              backgroundColor: colors.secondaryContainer,
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}
