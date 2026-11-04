import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/test_review_prompt.dart';
import 'test_result_review_card.dart';

class TestResultReview extends StatelessWidget {
  const TestResultReview({required this.result, super.key});

  final QuizAttemptModel result;

  @override
  Widget build(BuildContext context) {
    final Map<String, TestQuestionModel> questions =
        <String, TestQuestionModel>{
          for (final TestQuestionModel question in result.questions)
            question.id: question,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          LangKeys.quizReviewTitle.tr(),
          style: AppTheme.styles(context).labelStrong,
        ),
        SizedBox(height: 10.h),
        for (final QuizQuestionResultModel item in result.questionResults)
          TestResultReviewCard(
            result: item,
            question: questions[item.questionId],
            prompt: TestReviewPrompt.of(
              result: item,
              question: questions[item.questionId],
            ),
          ),
      ],
    );
  }
}
