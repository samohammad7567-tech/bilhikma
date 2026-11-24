import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_content_width.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/status_header.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AccountApprovedBody extends StatelessWidget {
  const AccountApprovedBody({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: AppContentWidth(
        maxWidth: 600,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (50).w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: (24).h(context)),

              StatusHeader(
                title: context.tr('account_approved'),
                note: 'account_approved_note'.tr(),
              ),

              Expanded(
                child: Center(
                  child: AppIcon(
                    asset: AppAssets.assetsAccountAccepted,
                    size: (70).r(context),
                  ),
                ),
              ),

              CustomButton(
                onPressed: onContinue,
                text: 'login'.tr(),
                width: double.infinity,
                height: (40).h(context),
                threeRadius: 8,
                lastRadius: 8,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                elevation: (0).r(context),
              ),

              SizedBox(height: (24).h(context)),
            ],
          ),
        ),
      ),
    );
  }
}
