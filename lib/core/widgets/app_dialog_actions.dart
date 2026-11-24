import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_outline_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppDialogActions extends StatelessWidget {
  const AppDialogActions({
    required this.confirmKey,
    required this.cancelKey,
    required this.onConfirm,
    required this.onCancel,
    super.key,
    this.confirmColor,
  });

  final String confirmKey;
  final String cancelKey;

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  final Color? confirmColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: onConfirm,
            text: confirmKey.tr(),
            width: double.infinity,
            height: (44).h(context),
            threeRadius: 8,
            lastRadius: 8,
            backgroundColor: confirmColor ?? colors.error,
            textColor: colors.onError,
            elevation: (0).r(context),
          ),
        ),

        SizedBox(width: (12).w(context)),

        Expanded(
          child: CustomOutlineButton(
            onPressed: onCancel,
            text: cancelKey.tr(),
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
