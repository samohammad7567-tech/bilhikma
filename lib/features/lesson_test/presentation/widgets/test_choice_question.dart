import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../data/models/test_answer_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import 'test_option_tile.dart';
import 'test_question_prompt.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
          rich: question.isRichPrompt,
        ),

        if (question.isBestAnswer) ...<Widget>[
          SizedBox(height: (8).h(context)),
          Text(LangKeys.quizBestAnswer.tr()),
        ],

        SizedBox(height: (18).h(context)),

        if (question.type.isTrueFalse)
          ..._booleanChoices(context)
        else
          for (final TestOptionModel option in question.options)
            Padding(
              padding: EdgeInsets.only(bottom: (12).h(context)),
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

  List<Widget> _booleanChoices(BuildContext context) => <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: (12).h(context)),
          child: TestOptionTile(
            label: LangKeys.quizTrue.tr(),
            isSelected: answer.boolean == true,
            isMultiSelect: false,
            onTap: () => onSelect('true'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: (12).h(context)),
          child: TestOptionTile(
            label: LangKeys.quizFalse.tr(),
            isSelected: answer.boolean == false,
            isMultiSelect: false,
            onTap: () => onSelect('false'),
          ),
        ),
      ];
}
