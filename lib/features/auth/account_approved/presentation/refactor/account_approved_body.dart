import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/status_header.dart';

class AccountApprovedBody extends StatelessWidget {
  const AccountApprovedBody({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 24.h),

            StatusHeader(
              title: context.tr('account_approved'),
              note: 'account_approved_note'.tr(),
            ),

            Expanded(
              child: Center(
                child: AppIcon(
                  asset: AppAssets.assetsAccountAccepted,
                  size: 70.w,
                ),
              ),
            ),

            CustomButton(
              onPressed: onContinue,
              text: 'login'.tr(),
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
