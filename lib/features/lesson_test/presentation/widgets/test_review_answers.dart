import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import '../refactor/quiz_review_answer.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';

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
          if (index > 0) SizedBox(height: 8.h),
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
        SizedBox(height: 3.h),
        for (final QuizReviewAnswer answer in answers) _answer(context, answer),
      ],
    );
  }

  Widget _answer(BuildContext context, QuizReviewAnswer answer) {
    final AppTextStyles styles = AppTheme.styles(context);
    final String? imageUrl = answer.imageUrl?.trim();
    final String feedback = answer.normalizedFeedback;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (imageUrl != null && imageUrl.isNotEmpty) ...<Widget>[
            TestMediaImage(
              url: imageUrl,
              width: 52.w,
              height: 52.h,
              radius: 10,
              elevated: false,
              padding: EdgeInsets.all(3.w),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (answer.text.trim().isNotEmpty)
                  TestHtmlText(answer.text.trim(), style: styles.labelSmall),
                if (feedback.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: TestHtmlText(
                      '${LangKeys.quizOptionFeedback.tr()}: $feedback',
                      style: styles.labelSmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _explanation(BuildContext context, String text) {
    final AppTextStyles styles = AppTheme.styles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${LangKeys.quizExplanation.tr()}:', style: styles.labelStrong),
        SizedBox(height: 3.h),
        TestHtmlText(text, style: styles.labelSmall),
      ],
    );
  }
}
