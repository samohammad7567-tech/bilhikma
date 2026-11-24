import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class BackToLoginRow extends StatelessWidget {
  const BackToLoginRow({super.key, this.onLogin});

  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            'remembered_password'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(
              context,
            ).linkLabel.copyWith(color: colors.onSurface),
          ),
        ),

        SizedBox(width: (6).w(context)),

        Flexible(
          child: GestureDetector(
            onTap: onLogin,
            child: Text(
              'login'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).linkLabel.copyWith(
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: colors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
