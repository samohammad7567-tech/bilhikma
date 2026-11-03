import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_theme.dart';

class RejectionReasonCard extends StatelessWidget {
  const RejectionReasonCard({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'rejection_reason'.tr(),
              textAlign: TextAlign.center,
              style: AppTheme.styles(
                context,
              ).bodyStrong.copyWith(color: colors.secondary),
            ),
            SizedBox(height: 6.h),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: AppTheme.styles(context).bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
