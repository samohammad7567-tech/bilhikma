import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/app_info_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_header.dart';
import '../../data/models/app_version_model.dart';
import '../widgets/app_update_message_card.dart';

/// The dead end for `force_update` and `maintenance`.
///
/// There is no "later" and no back button: both statuses mean the app cannot be
/// used at all. `force_update` gets the one action that resolves it — the
/// download link. `maintenance` gets none, because nothing the user can do
/// fixes it; they are told to come back.
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 24.h),

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
                    SizedBox(height: 24.h),

                    Icon(
                      isMaintenance
                          ? Icons.build_circle_outlined
                          : Icons.system_update_alt_rounded,
                      size: 70.w,
                      color: colors.secondary,
                    ),

                    if (version.hasMessage) ...<Widget>[
                      SizedBox(height: 24.h),
                      AppUpdateMessageCard(message: version.message!),
                    ],

                    if (!isMaintenance) ...<Widget>[
                      SizedBox(height: 20.h),
                      _VersionLine(version: version),
                    ],

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            if (!isMaintenance && version.hasStoreUrl)
              CustomButton(
                onPressed: onUpdate,
                text: 'update_now'.tr(),
                width: double.infinity,
                height: 44.h,
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
          SizedBox(height: 6.h),
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
