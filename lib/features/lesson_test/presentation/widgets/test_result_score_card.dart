import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../data/models/quiz_attempt_model.dart';

class TestResultScoreCard extends StatelessWidget {
  const TestResultScoreCard({required this.result, super.key});

  final QuizAttemptModel result;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool passed = result.isPassed == true;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: passed
            ? colors.tertiaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                LangKeys.quizScoreValue.tr(
                  namedArgs: <String, String>{
                    'score': _number(result.score),
                    'max': _number(result.maxScore),
                  },
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTheme.styles(context).statusTitle,
              ),
            ),

            VerticalDivider(
              width: 1.w,
              thickness: 1,
              color: colors.onSurface.withValues(alpha: 0.2),
            ),

            Expanded(
              child: Text(
                '${result.scorePercent ?? 0} %',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTheme.styles(context).statusTitle.copyWith(
                  color: passed ? colors.onSurfaceVariant : colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _number(double? value) {
    if (value == null) return '-';

    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
