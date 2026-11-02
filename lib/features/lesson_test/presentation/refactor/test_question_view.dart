import 'package:flutter/material.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/test_choice_question.dart';
import '../widgets/test_dropdown_blanks_question.dart';
import '../widgets/test_fill_blanks_question.dart';
import '../widgets/test_match_pairs_question.dart';
import '../widgets/test_order_sentences_question.dart';
import '../widgets/test_typed_blanks_question.dart';

class TestQuestionView extends StatelessWidget {
  const TestQuestionView({
    required this.cubit,
    required this.state,
    required this.question,
    required this.questionRemaining,
    super.key,
  });

  final LessonTestCubit cubit;
  final LessonTestState state;
  final TestQuestionModel question;

  final Duration? questionRemaining;

  @override
  Widget build(BuildContext context) {
    final TestAnswerModel answer = state.answerOf(question.id);

    switch (question.type) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.multiChoice:
      case TestQuestionType.mostCorrect:
      case TestQuestionType.trueFalse:
        return TestChoiceQuestion(
          question: question,
          questionRemaining: questionRemaining,
          answer: answer,
          onSelect: question.type.isTrueFalse
              ? (String optionId) {
                  final bool value = optionId.toLowerCase() == 'true';
                  cubit.selectBoolean(value);
                }
              : cubit.selectOption,
        );

      case TestQuestionType.fillBlanks:
        if (question.blankInputMode?.key == 'dropdown') {
          return TestDropdownBlanksQuestion(
            question: question,
          questionRemaining: questionRemaining,
            answer: answer,
            selectedBlankId: state.selectedBlankId,
            onBlankTap: (String blankId) => answer.blankValue(blankId) == null
                ? cubit.selectBlank(blankId)
                : cubit.clearBlank(blankId),
            onChoiceSelected: (String blankId, String optionId) =>
                cubit.selectBlankChoice(blankId: blankId, optionId: optionId),
          );
        }

        return TestFillBlanksQuestion(
          question: question,
          questionRemaining: questionRemaining,
          answer: answer,
          selectedBlankId: state.selectedBlankId,
          onBlankTap: (String blankId) => answer.blankValue(blankId) == null
              ? cubit.selectBlank(blankId)
              : cubit.clearBlank(blankId),
          onWordTap: cubit.assignWord,
        );

      case TestQuestionType.typedBlanks:
        return TestTypedBlanksQuestion(
          question: question,
          questionRemaining: questionRemaining,
          answer: answer,
          selectedBlankId: state.selectedBlankId,
          onBlankTap: cubit.selectBlank,
          onTyped: cubit.typeBlank,
        );

      case TestQuestionType.matchPairs:
        return TestMatchPairsQuestion(
          question: question,
          questionRemaining: questionRemaining,
          answer: answer,
          matchOrder: state.rightOrderOf(question.id),
          selectedPromptId: state.selectedPromptId,
          onPromptTap: cubit.selectPrompt,
          onMatchTap: cubit.linkMatch,
        );

      case TestQuestionType.orderSentences:
        return TestOrderSentencesQuestion(
          question: question,
          questionRemaining: questionRemaining,
          answer: answer,
          onReorder: cubit.reorderSentences,
        );
    }
  }
}
