import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/test_solution_answers.dart';
import 'test_html_text.dart';

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
    final _Status status = _statusOf(colors);
    final List<String> correctAnswers = TestSolutionAnswers.of(
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
            TestHtmlText(prompt, style: AppTheme.styles(context).labelStrong),

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

          if (correctAnswers.isNotEmpty) ...<Widget>[
            SizedBox(height: 8.h),
            TestHtmlText(
              '${LangKeys.quizCorrectAnswer.tr()}: '
              '${correctAnswers.join(' | ')}',
              style: AppTheme.styles(context).labelSmall,
            ),
          ],

          if (explanation != null) ...<Widget>[
            SizedBox(height: 8.h),
            TestHtmlText(
              '${LangKeys.quizExplanation.tr()}: $explanation',
              style: AppTheme.styles(context).labelSmall,
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

  _Status _statusOf(ColorScheme colors) {
    if (result.isCorrect == true) {
      return _Status(
        icon: Icons.check_circle,
        label: LangKeys.quizAnswerCorrect.tr(),
        color: colors.primary,
      );
    }

    if (!result.hasGivenAnswer) {
      return _Status(
        icon: Icons.remove_circle_outline,
        label: LangKeys.quizNotAnswered.tr(),
        color: colors.outline,
      );
    }

    if (result.isCorrect == false) {
      return _Status(
        icon: Icons.cancel,
        label: LangKeys.quizAnswerIncorrect.tr(),
        color: colors.error,
      );
    }

    return _Status(
      icon: Icons.hourglass_empty,
      label: LangKeys.quizPendingReview.tr(),
      color: colors.outline,
    );
  }

  String _number(double? value) {
    if (value == null) return '-';

    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _Status {
  const _Status({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;
}
