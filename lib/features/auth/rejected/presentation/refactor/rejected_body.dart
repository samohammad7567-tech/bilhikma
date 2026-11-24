import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/widgets/app_content_width.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/status_header.dart';
import '../widgets/rejection_reason_card.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class RejectedBody extends StatelessWidget {
  const RejectedBody({this.reason, this.onBackToLogin, super.key});

  final String? reason;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? reasonText = reason;

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
                title: context.tr('request_rejected'),
                note: 'request_rejected_note'.tr(),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppIcon(asset: AppAssets.assetsAccountRejected, size: (70).r(context)),

                    if (reasonText != null &&
                        reasonText.isNotEmpty) ...<Widget>[
                      SizedBox(height: (24).h(context)),
                      RejectionReasonCard(reason: reasonText),
                    ],
                  ],
                ),
              ),

              CustomButton(
                onPressed:
                    onBackToLogin ??
                    () => Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    ),
                text: 'ok'.tr(),
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
