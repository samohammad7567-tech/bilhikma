import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/custom_outline_button.dart';

class TestResultActionBar extends StatelessWidget {
  const TestResultActionBar({required this.onBackToLesson, super.key});

  final VoidCallback onBackToLesson;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 8,
      shadowColor: colors.shadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: CustomOutlineButton(
            onPressed: onBackToLesson,
            text: LangKeys.backToLesson.tr(),
            width: double.infinity,
            height: 46.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            borderColor: colors.secondary,
            textColor: colors.secondary,
          ),
        ),
      ),
    );
  }
}
