import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../data/models/app_version_model.dart';
import 'app_update_dialog_actions.dart';
import 'app_update_dialog_header.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({required this.version, super.key});

  final AppVersionModel version;

  static Future<bool> show(
    BuildContext context,
    AppVersionModel version,
  ) async {
    final bool? wantsUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) =>
          AppUpdateDialog(version: version),
    );

    return wantsUpdate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      elevation: (0).r(context),
      insetPadding: EdgeInsets.symmetric(horizontal: (28).w(context)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((20).r(context))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (18).w(context), vertical: (20).h(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AppUpdateDialogHeader(),

            SizedBox(height: (16).h(context)),

            Text(
              version.hasMessage
                  ? version.message!
                  : 'update_available_note'.tr(),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7.h(context)),
            ),

            if (version.latestVersion.isNotEmpty) ...<Widget>[
              SizedBox(height: (10).h(context)),
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

            SizedBox(height: (22).h(context)),

            const AppUpdateDialogActions(),
          ],
        ),
      ),
    );
  }
}
