import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../themes/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_outline_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
      elevation: (0).r(context),
      insetPadding: EdgeInsets.symmetric(horizontal: (28).w(context)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((20).r(context))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (18).w(context), vertical: (20).h(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _LogoutHeader(),

            SizedBox(height: (16).h(context)),

            Text(
              'logout_confirm'.tr(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodySmall.copyWith(height: 1.7.h(context)),
            ),

            SizedBox(height: (22).h(context)),

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
          width: (38).w(context),
          height: (38).h(context),
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular((10).r(context)),
          ),
          child: Icon(
            Icons.logout_rounded,
            size: (20).r(context),
            color: colors.onSecondary,
          ),
        ),

        SizedBox(width: (12).w(context)),

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
            height: (44).h(context),
            threeRadius: 8,
            lastRadius: 8,
            backgroundColor: colors.secondary,
            textColor: colors.onSecondary,
            elevation: (0).r(context),
          ),
        ),

        SizedBox(width: (12).w(context)),

        Expanded(
          child: CustomOutlineButton(
            onPressed: () => Navigator.of(context).pop(false),
            text: 'cancel'.tr(),
            width: double.infinity,
            height: (44).h(context),
            threeRadius: 8,
            lastRadius: 8,
            borderColor: colors.secondary,
            textColor: colors.secondary,
          ),
        ),
      ],
    );
  }
}
