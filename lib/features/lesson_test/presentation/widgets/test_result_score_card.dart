import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/test_result_model.dart';
import '../../../../core/themes/app_theme.dart';

class TestResultScoreCard extends StatelessWidget {
  const TestResultScoreCard({required this.result, super.key});

  final TestResultModel result;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool passed = result.passed;

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
                'score_value'.tr(
                  namedArgs: <String, String>{
                    'correct': '${result.correctCount}',
                    'total': '${result.totalCount}',
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
                '${result.scorePercent} %',
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
}
