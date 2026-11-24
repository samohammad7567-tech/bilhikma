import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class AppUpdateDialogActions extends StatelessWidget {
  const AppUpdateDialogActions({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'update_now'.tr(),
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
            text: 'remind_me_later'.tr(),
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
