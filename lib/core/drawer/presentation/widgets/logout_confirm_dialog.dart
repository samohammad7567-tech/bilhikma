import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../themes/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_outline_button.dart';

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => const LogoutConfirmDialog(),
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
            const _LogoutHeader(),

            SizedBox(height: 16.h),

            Text(
              'logout_confirm'.tr(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7),
            ),

            SizedBox(height: 22.h),

            const _LogoutActions(),
          ],
        ),
      ),
    );
  }
}

class _LogoutHeader extends StatelessWidget {
  const _LogoutHeader();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.logout_rounded,
            size: 20.w,
            color: colors.onSecondary,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Text(
            'logout'.tr(),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).sectionTitle,
          ),
        ),
      ],
    );
  }
}

class _LogoutActions extends StatelessWidget {
  const _LogoutActions();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'logout'.tr(),
            width: double.infinity,
            height: 44.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            backgroundColor: colors.secondary,
            textColor: colors.onSecondary,
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
