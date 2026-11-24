import 'package:flutter/material.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import 'test_blank_body_text.dart';
import 'test_question_prompt.dart';
import 'test_word_bank.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
          prompt: question.shouldShowPrompt ? question.displayPrompt : '',
          remaining: questionRemaining,
          imageUrl: question.imageUrl,
          audioUrl: question.audioUrl,
          rich: question.isRichPrompt,
        ),

        SizedBox(height: (20).h(context)),

        TestBlankBodyText(
          body: question.body,
          valueOf: _labelOf,
          onBlankTap: onBlankTap,
          selectedBlankId: selectedBlankId,
        ),

        SizedBox(height: (40).h(context)),

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
