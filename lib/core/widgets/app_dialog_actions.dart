import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_button.dart';
import 'custom_outline_button.dart';

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
            height: 44.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            backgroundColor: confirmColor ?? colors.error,
            textColor: colors.onError,
            elevation: 0,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: CustomOutlineButton(
            onPressed: onCancel,
            text: cancelKey.tr(),
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
