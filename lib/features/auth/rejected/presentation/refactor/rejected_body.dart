import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/status_header.dart';
import '../widgets/rejection_reason_card.dart';

class RejectedBody extends StatelessWidget {
  const RejectedBody({this.reason, this.onBackToLogin, super.key});

  final String? reason;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? reasonText = reason;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 24.h),

            StatusHeader(
              title: context.tr('request_rejected'),
              note: 'request_rejected_note'.tr(),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppIcon(asset: AppAssets.assetsAccountRejected, size: 70.w),

                  if (reasonText != null && reasonText.isNotEmpty) ...<Widget>[
                    SizedBox(height: 24.h),
                    RejectionReasonCard(reason: reasonText),
                  ],
                ],
              ),
            ),

            CustomButton(
              onPressed:
                  onBackToLogin ??
                  () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
              text: 'ok'.tr(),
              width: double.infinity,
              height: 40,
              threeRadius: 8.r,
              lastRadius: 8.r,
              backgroundColor: colors.secondary,
              textColor: colors.onSecondary,
              elevation: 0,
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
