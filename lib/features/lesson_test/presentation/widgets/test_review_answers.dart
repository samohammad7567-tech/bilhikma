import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../refactor/quiz_review_answer.dart';
import 'test_html_text.dart';
import 'test_review_answer_tile.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestReviewAnswers extends StatelessWidget {
  const TestReviewAnswers({
    required this.givenAnswers,
    required this.correctAnswers,
    super.key,
    this.explanation,
  });

  final List<QuizReviewAnswer> givenAnswers;
  final List<QuizReviewAnswer> correctAnswers;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = <Widget>[
      if (givenAnswers.isNotEmpty)
        _section(context, LangKeys.quizYourAnswer, givenAnswers),
      if (correctAnswers.isNotEmpty)
        _section(context, LangKeys.quizCorrectAnswer, correctAnswers),
      if (explanation != null && explanation!.trim().isNotEmpty)
        _explanation(context, explanation!.trim()),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < sections.length; index++) ...<Widget>[
          if (index > 0) SizedBox(height: (8).h(context)),
          sections[index],
        ],
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String labelKey,
    List<QuizReviewAnswer> answers,
  ) {
    final AppTextStyles styles = AppTheme.styles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${labelKey.tr()}:', style: styles.labelStrong),
        SizedBox(height: (3).h(context)),
        for (final QuizReviewAnswer answer in answers)
          TestReviewAnswerTile(answer: answer),
      ],
    );
  }

  Widget _explanation(BuildContext context, String text) {
    final AppTextStyles styles = AppTheme.styles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${LangKeys.quizExplanation.tr()}:', style: styles.labelStrong),
        SizedBox(height: (3).h(context)),
        TestHtmlText(text, style: styles.labelSmall),
      ],
    );
  }
}
