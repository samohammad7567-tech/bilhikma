import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';
import '../themes/app_theme.dart';
import 'app_dialog_actions.dart';
import 'app_dialog_glyph.dart';

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.titleKey,
    required this.messageKey,
    required this.confirmKey,
    super.key,
    this.cancelKey = 'cancel',
    this.iconPath = AppAssets.assetsDeleteIcon,
    this.messageArgs,
  });

  final String titleKey;
  final String messageKey;
  final String confirmKey;
  final String cancelKey;
  final String iconPath;

  final Map<String, String>? messageArgs;

  static Future<bool> show(
    BuildContext context, {
    required String titleKey,
    required String messageKey,
    required String confirmKey,
    String cancelKey = 'cancel',
    String iconPath = AppAssets.assetsDeleteIcon,
    Map<String, String>? messageArgs,
  }) async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppConfirmDialog(
        titleKey: titleKey,
        messageKey: messageKey,
        confirmKey: confirmKey,
        cancelKey: cancelKey,
        iconPath: iconPath,
        messageArgs: messageArgs,
      ),
    );

    return isConfirmed ?? false;
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
            Row(
              children: <Widget>[
                AppDialogGlyph(imagePath: iconPath),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    titleKey.tr(),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.styles(context).sectionTitle,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Text(
              messageKey.tr(namedArgs: messageArgs),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7),
            ),

            SizedBox(height: 22.h),

            AppDialogActions(
              confirmKey: confirmKey,
              cancelKey: cancelKey,
              onConfirm: () => Navigator.of(context).pop(true),
              onCancel: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
