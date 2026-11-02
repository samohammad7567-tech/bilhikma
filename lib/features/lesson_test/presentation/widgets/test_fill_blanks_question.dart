import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/test_blank_segments.dart';
import 'test_blank_text.dart';
import 'test_question_prompt.dart';
import 'test_word_bank.dart';

class TestFillBlanksQuestion extends StatelessWidget {
  const TestFillBlanksQuestion({
    required this.question,
    required this.answer,
    required this.onBlankTap,
    required this.onWordTap,
    super.key,
    this.selectedBlankId,
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final ValueChanged<String> onBlankTap;
  final ValueChanged<String> onWordTap;

  final String? selectedBlankId;
  final Duration? questionRemaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: question.prompt,
          remaining: questionRemaining,
        ),

        SizedBox(height: 20.h),

        TestBlankText(
          segments: TestBlankSegments.parse(question.body),
          valueOf: _labelOf,
          onBlankTap: onBlankTap,
          selectedBlankId: selectedBlankId,
        ),

        SizedBox(height: 40.h),

        TestWordBank(
          options: question.options,
          isUsed: (String optionId) =>
              answer.usesOption(optionId) &&
              !(question.optionById(optionId)?.isReusable ?? false),
          onSelect: onWordTap,
        ),
      ],
    );
  }

  String? _labelOf(String blankId) {
    final String? optionId = answer.blankValue(blankId);
    if (optionId == null) return null;

    return question.optionById(optionId)?.label;
  }
}
