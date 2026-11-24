import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonLockedView extends StatelessWidget {
  const LessonLockedView({required this.onBack, super.key, this.message});
  final String? message;

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);
    final String? message = this.message;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all((32).r(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(
              asset: AppAssets.assetsLockIcon,
              size: (56).r(context),
              color: colors.secondary,
            ),

            SizedBox(height: (16).h(context)),

            Text(
              'lesson_locked_title'.tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.cardTitle,
            ),

            SizedBox(height: (8).h(context)),

            Text(
              message ?? 'lesson_locked_hint'.tr(),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: styles.bodyLarge.copyWith(color: colors.secondary),
            ),

            SizedBox(height: (24).h(context)),

            CustomButton(
              onPressed: onBack,
              text: 'back_to_lessons'.tr(),
              width: double.infinity,
              height: (44).h(context),
              threeRadius: 8,
              lastRadius: 8,
              backgroundColor: colors.secondaryContainer,
              elevation: (0).r(context),
            ),
          ],
        ),
      ),
    );
  }
}
