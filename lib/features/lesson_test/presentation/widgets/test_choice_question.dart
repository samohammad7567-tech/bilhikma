import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
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
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final Duration? questionRemaining;

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final bool isMultiSelect = question.type.isMultiSelect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: question.prompt,
          remaining: questionRemaining,
          imageUrl: question.imageUrl,
          audioUrl: question.audioUrl,
        ),

        if (question.isBestAnswer) ...<Widget>[
          SizedBox(height: 8.h),
          Text(LangKeys.quizBestAnswer.tr()),
        ],

        SizedBox(height: 18.h),

        if (question.type.isTrueFalse)
          ..._booleanChoices
        else
          for (final TestOptionModel option in question.options)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TestOptionTile(
                label: option.label,
                imageUrl: option.imageUrl,
                audioUrl: option.audioUrl,
                isSelected: answer.optionIds.contains(option.id),
                isMultiSelect: isMultiSelect,
                onTap: () => onSelect(option.id),
              ),
            ),
      ],
    );
  }

  List<Widget> get _booleanChoices => <Widget>[
    Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TestOptionTile(
        label: LangKeys.quizTrue.tr(),
        isSelected: answer.boolean == true,
        isMultiSelect: false,
        onTap: () => onSelect('true'),
      ),
    ),
    Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TestOptionTile(
        label: LangKeys.quizFalse.tr(),
        isSelected: answer.boolean == false,
        isMultiSelect: false,
        onTap: () => onSelect('false'),
      ),
    ),
  ];
}
