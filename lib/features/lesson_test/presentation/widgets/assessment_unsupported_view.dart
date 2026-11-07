import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';

class AssessmentUnsupportedView extends StatelessWidget {
  const AssessmentUnsupportedView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 44.w, color: colors.outline),
            SizedBox(height: 12.h),
            Text(
              LangKeys.assessmentUnsupportedTitle.tr(),
              textAlign: TextAlign.center,
              style: styles.cardTitle.copyWith(color: colors.onSurface),
            ),
            SizedBox(height: 8.h),
            Text(
              LangKeys.assessmentUnsupportedMessage.tr(),
              textAlign: TextAlign.center,
              style: styles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
