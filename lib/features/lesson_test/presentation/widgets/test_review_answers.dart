import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/themes/app_theme.dart';
import 'test_html_text.dart';

class TestReviewAnswers extends StatelessWidget {
  const TestReviewAnswers({
    required this.givenAnswers,
    required this.correctAnswers,
    super.key,
    this.explanation,
  });

  final List<String> givenAnswers;
  final List<String> correctAnswers;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      if (givenAnswers.isNotEmpty)
        _row(context, LangKeys.quizYourAnswer, givenAnswers),
      if (correctAnswers.isNotEmpty)
        _row(context, LangKeys.quizCorrectAnswer, correctAnswers),
      if (explanation != null && explanation!.trim().isNotEmpty)
        _row(context, LangKeys.quizExplanation, <String>[explanation!.trim()]),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < rows.length; index++) ...<Widget>[
          if (index > 0) SizedBox(height: 8.h),
          rows[index],
        ],
      ],
    );
  }

  Widget _row(BuildContext context, String labelKey, List<String> values) {
    return TestHtmlText(
      '${labelKey.tr()}: ${values.join(' | ')}',
      style: AppTheme.styles(context).labelSmall,
    );
  }
}
