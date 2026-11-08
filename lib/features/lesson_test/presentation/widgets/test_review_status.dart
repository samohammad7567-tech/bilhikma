import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../data/models/quiz_question_result_model.dart';

class TestReviewStatus {
  const TestReviewStatus({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

TestReviewStatus testReviewStatusOf(
  QuizQuestionResultModel result,
  ColorScheme colors,
) {
  if (result.isCorrect == true) {
    return TestReviewStatus(
      icon: Icons.check_circle,
      label: LangKeys.quizAnswerCorrect.tr(),
      color: colors.primary,
    );
  }

  if (!result.hasGivenAnswer) {
    return TestReviewStatus(
      icon: Icons.remove_circle_outline,
      label: LangKeys.quizNotAnswered.tr(),
      color: colors.outline,
    );
  }

  if (result.isCorrect == false) {
    return TestReviewStatus(
      icon: Icons.cancel,
      label: LangKeys.quizAnswerIncorrect.tr(),
      color: colors.error,
    );
  }

  return TestReviewStatus(
    icon: Icons.hourglass_empty,
    label: LangKeys.quizPendingReview.tr(),
    color: colors.outline,
  );
}
