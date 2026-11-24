import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/app_info_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/app_content_width.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_header.dart';
import '../../data/models/app_version_model.dart';
import '../widgets/app_update_message_card.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppUpdateBlockedBody extends StatelessWidget {
  const AppUpdateBlockedBody({
    required this.version,
    required this.onUpdate,
    super.key,
  });

  final AppVersionModel version;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isMaintenance = version.status.isMaintenance;

    return SafeArea(
      child: AppContentWidth(
        maxWidth: 600,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (32).w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: (24).h(context)),

              StatusHeader(
                title: isMaintenance
                    ? 'maintenance_title'.tr()
                    : 'update_required'.tr(),
                note: isMaintenance
                    ? 'maintenance_note'.tr()
                    : 'update_required_note'.tr(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: (24).h(context)),

                      Icon(
                        isMaintenance
                            ? Icons.build_circle_outlined
                            : Icons.system_update_alt_rounded,
                        size: (70).r(context),
                        color: colors.secondary,
                      ),

                      if (version.hasMessage) ...<Widget>[
                        SizedBox(height: (24).h(context)),
                        AppUpdateMessageCard(message: version.message!),
                      ],

                      if (!isMaintenance) ...<Widget>[
                        SizedBox(height: (20).h(context)),
                        _VersionLine(version: version),
                      ],

                      SizedBox(height: (24).h(context)),
                    ],
                  ),
                ),
              ),

              if (!isMaintenance && version.hasStoreUrl)
                CustomButton(
                  onPressed: onUpdate,
                  text: 'update_now'.tr(),
                  width: double.infinity,
                  height: (44).h(context),
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

class _VersionLine extends StatelessWidget {
  const _VersionLine({required this.version});

  final AppVersionModel version;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'app_update_current_version'.tr(
            namedArgs: <String, String>{'version': AppInfoService.fullVersion},
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).note,
        ),

        if (version.latestVersion.isNotEmpty) ...<Widget>[
          SizedBox(height: (6).h(context)),
          Text(
            'app_update_latest_version'.tr(
              namedArgs: <String, String>{'version': version.latestVersion},
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).note,
          ),
        ],
      ],
    );
  }
}
