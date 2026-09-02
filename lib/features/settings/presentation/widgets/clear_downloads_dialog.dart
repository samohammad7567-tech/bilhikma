import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import 'settings_glyph_tile.dart';

class ClearDownloadsDialog extends StatelessWidget {
  const ClearDownloadsDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => const ClearDownloadsDialog(),
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
            const _ClearDownloadsHeader(),

            SizedBox(height: 16.h),

            Text(
              'clear_downloads_confirm'.tr(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7),
            ),

            SizedBox(height: 22.h),

            const _ClearDownloadsActions(),
          ],
        ),
      ),
    );
  }
}

class _ClearDownloadsHeader extends StatelessWidget {
  const _ClearDownloadsHeader();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        SettingsGlyphTile(
          imagePath: AppAssets.assetsDeleteIcon,
          backgroundColor: colors.error.withValues(alpha: 0.75),
          iconColor: colors.onError,
        ),
        SizedBox(width: 12.w),

        Text(
          'clear_all_downloads'.tr(),
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).sectionTitle,
        ),
      ],
    );
  }
}

class _ClearDownloadsActions extends StatelessWidget {
  const _ClearDownloadsActions();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'clear_all'.tr(),
            width: double.infinity,
            height: 44.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            backgroundColor: colors.error,
            textColor: colors.onError,
            elevation: 0,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: CustomOutlineButton(
            onPressed: () => Navigator.of(context).pop(false),
            text: 'cancel'.tr(),
            width: double.infinity,
            height: 44.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            borderColor: colors.secondary,
            textColor: colors.secondary,
          ),
        ),
      ],
    );
  }
}
