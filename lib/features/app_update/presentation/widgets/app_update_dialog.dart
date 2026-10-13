import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../data/models/app_version_model.dart';
import 'app_update_dialog_actions.dart';
import 'app_update_dialog_header.dart';

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
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AppUpdateDialogHeader(),

            SizedBox(height: 16.h),

            Text(
              version.hasMessage
                  ? version.message!
                  : 'update_available_note'.tr(),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7),
            ),

            if (version.latestVersion.isNotEmpty) ...<Widget>[
              SizedBox(height: 10.h),
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

            SizedBox(height: 22.h),

            const AppUpdateDialogActions(),
          ],
        ),
      ),
    );
  }
}
