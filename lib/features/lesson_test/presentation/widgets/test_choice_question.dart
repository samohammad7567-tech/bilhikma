import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import 'test_option_tile.dart';
import 'test_question_prompt.dart';

class TestChoiceQuestion extends StatelessWidget {
  const TestChoiceQuestion({
    required this.question,
    required this.answer,
    required this.onSelect,
    super.key,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final bool isMultiSelect = question.type.isMultiSelect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(prompt: question.prompt),

        SizedBox(height: 18.h),

        for (final TestOptionModel option in question.options)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: TestOptionTile(
              label: option.label,
              isSelected: answer.optionIds.contains(option.id),
              isMultiSelect: isMultiSelect,
              onTap: () => onSelect(option.id),
            ),
          ),
      ],
    );
  }
}
