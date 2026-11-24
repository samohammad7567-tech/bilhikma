import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/custom_outline_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestResultActionBar extends StatelessWidget {
  const TestResultActionBar({required this.onBackToLesson, super.key});

  final VoidCallback onBackToLesson;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: (8).r(context),
      shadowColor: colors.shadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB((16).w(context), (12).h(context), (16).w(context), (12).h(context)),
          child: CustomOutlineButton(
            onPressed: onBackToLesson,
            text: LangKeys.backToLesson.tr(),
            width: double.infinity,
            height: (46).h(context),
            threeRadius: 8,
            lastRadius: 8,
            borderColor: colors.secondary,
            textColor: colors.secondary,
          ),
        ),
      ),
    );
  }
}
