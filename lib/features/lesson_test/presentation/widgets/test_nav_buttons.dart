import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_outline_button.dart';

class TestNavButtons extends StatelessWidget {
  const TestNavButtons({
    required this.isFirstQuestion,
    required this.isLastQuestion,
    required this.onNext,
    required this.onPrevious,
    super.key,
  });

  final bool isFirstQuestion;
  final bool isLastQuestion;

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double height = 46.h;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: onNext,
            text: isLastQuestion ? 'finish_test'.tr() : 'next_question'.tr(),
            width: double.infinity,
            height: height,
            threeRadius: 8.r,
            lastRadius: 8.r,
            backgroundColor: colors.secondary,
            textColor: colors.onSecondary,
            elevation: 0,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Opacity(
            opacity: isFirstQuestion ? 0.5 : 1,
            child: CustomOutlineButton(
              onPressed: isFirstQuestion ? () {} : onPrevious,
              text: 'previous_question'.tr(),
              width: double.infinity,
              height: height,
              threeRadius: 8.r,
              lastRadius: 8.r,
              borderColor: colors.secondary,
              textColor: colors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
