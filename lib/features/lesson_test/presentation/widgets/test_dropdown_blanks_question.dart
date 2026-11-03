import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_blank_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/test_blank_segments.dart';
import 'test_blank_text.dart';
import 'test_option_tile.dart';
import 'test_question_prompt.dart';

class TestDropdownBlanksQuestion extends StatelessWidget {
  const TestDropdownBlanksQuestion({
    required this.question,
    required this.answer,
    required this.onBlankTap,
    required this.onChoiceSelected,
    super.key,
    this.selectedBlankId,
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final ValueChanged<String> onBlankTap;
  final void Function(String blankId, String optionId) onChoiceSelected;

  final String? selectedBlankId;
  final Duration? questionRemaining;

  @override
  Widget build(BuildContext context) {
    final TestBlankModel? activeBlank = _activeBlank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: question.shouldShowPrompt ? question.displayPrompt : '',
          remaining: questionRemaining,
        ),

        SizedBox(height: 20.h),

        TestBlankText(
          segments: TestBlankSegments.parse(question.body),
          valueOf: _labelOf,
          onBlankTap: onBlankTap,
          selectedBlankId: selectedBlankId,
        ),

        if (activeBlank != null && activeBlank.choices.isNotEmpty) ...<Widget>[
          SizedBox(height: 24.h),

          for (final TestOptionModel choice in activeBlank.choices)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: TestOptionTile(
                label: choice.label,
                isSelected: answer.blankValue(activeBlank.id) == choice.id,
                isMultiSelect: false,
                onTap: () => onChoiceSelected(activeBlank.id, choice.id),
              ),
            ),
        ],
      ],
    );
  }

  TestBlankModel? get _activeBlank {
    final String? selected = selectedBlankId;
    if (selected == null) return null;

    for (final TestBlankModel blank in question.blanks) {
      if (blank.id == selected) return blank;
    }
    return null;
  }

  String? _labelOf(String blankId) {
    final String? optionId = answer.blankValue(blankId);
    if (optionId == null) return null;

    for (final TestBlankModel blank in question.blanks) {
      if (blank.id != blankId) continue;

      for (final TestOptionModel choice in blank.choices) {
        if (choice.id == optionId) return choice.label;
      }
    }

    return question.optionById(optionId)?.label;
  }
}
