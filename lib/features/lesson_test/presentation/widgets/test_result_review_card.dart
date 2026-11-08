import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/quiz_review_answer.dart';
import '../refactor/test_given_answers.dart';
import '../refactor/test_solution_answers.dart';
import 'test_rich_prompt.dart';
import 'test_review_answers.dart';
import 'test_review_status.dart';

class TestResultReviewCard extends StatelessWidget {
  const TestResultReviewCard({
    required this.result,
    required this.prompt,
    super.key,
    this.question,
  });

  final QuizQuestionResultModel result;
  final TestQuestionModel? question;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TestReviewStatus status = testReviewStatusOf(result, colors);
    final List<QuizReviewAnswer> correctAnswers = TestSolutionAnswers.itemsOf(
      result,
      question: question,
    );
    final List<QuizReviewAnswer> givenAnswers = TestGivenAnswers.itemsOf(
      result,
      question: question,
    );
    final String? explanation = _explanation;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (prompt.trim().isNotEmpty)
            TestRichPrompt(
              prompt,
              rich: question?.isRichPrompt ?? false,
              style: AppTheme.styles(context).labelStrong,
            ),

          if (prompt.trim().isNotEmpty) SizedBox(height: 8.h),

          Row(
            children: <Widget>[
              Icon(status.icon, size: 18.w, color: status.color),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  status.label,
                  maxLines: 1,
                  style: AppTheme.styles(
                    context,
                  ).labelMedium.copyWith(color: status.color),
                ),
              ),
              Text(
                LangKeys.quizScoreValue.tr(
                  namedArgs: <String, String>{
                    'score': _number(result.awardedScore),
                    'max': _number(result.score),
                  },
                ),
                maxLines: 1,
                style: AppTheme.styles(context).labelSmall,
              ),
            ],
          ),

          if (givenAnswers.isNotEmpty ||
              correctAnswers.isNotEmpty ||
              explanation != null) ...<Widget>[
            SizedBox(height: 8.h),
            TestReviewAnswers(
              givenAnswers: givenAnswers,
              correctAnswers: correctAnswers,
              explanation: explanation,
            ),
          ],
        ],
      ),
    );
  }

  String? get _explanation {
    final String? top = result.explanation;
    if (top != null && top.trim().isNotEmpty) return top.trim();

    final Object? value = result.solution?['explanation'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  String _number(double? value) {
    if (value == null) return '-';

    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
