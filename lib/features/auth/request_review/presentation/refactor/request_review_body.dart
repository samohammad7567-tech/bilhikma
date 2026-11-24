import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/widgets/app_icon.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_content_width.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/status_header.dart';
import '../widgets/info_card.dart';
import '../widgets/info_item.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class RequestReviewBody extends StatelessWidget {
  const RequestReviewBody({
    required this.institution,
    required this.academicLevel,
    required this.phone,
    super.key,
    this.onBackToLogin,
  });

  final String institution;
  final String academicLevel;
  final String phone;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<InfoItem> items = <InfoItem>[
      InfoItem(
        iconAsset: AppAssets.assetsBookIcon,
        title: context.tr('institution'),
        value: institution,
      ),
      InfoItem(
        iconAsset: AppAssets.assetsClassIcon,
        title: context.tr('academic_level'),
        value: academicLevel,
      ),
      InfoItem(
        iconAsset: AppAssets.assetsPhoneIcon,
        title: context.tr('phone_number'),
        value: phone,
      ),
    ];

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
                title: context.tr('request_under_review'),
                note: 'request_under_review_note'.tr(),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppIcon(asset: AppAssets.assetsPending, size: (70).r(context)),

                    SizedBox(height: (24).h(context)),

                    InfoCard(items: items),
                  ],
                ),
              ),

              CustomButton(
                onPressed:
                    onBackToLogin ??
                    () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                text: 'back_to_login'.tr(),
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
