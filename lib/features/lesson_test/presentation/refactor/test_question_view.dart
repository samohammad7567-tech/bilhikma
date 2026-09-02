import 'package:flutter/material.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../cubit/lesson_test_cubit.dart';
import '../widgets/test_choice_question.dart';
import '../widgets/test_fill_blanks_question.dart';
import '../widgets/test_match_pairs_question.dart';
import '../widgets/test_order_sentences_question.dart';
import '../widgets/test_typed_blanks_question.dart';

class TestQuestionView extends StatelessWidget {
  const TestQuestionView({
    required this.cubit,
    required this.state,
    required this.question,
    super.key,
  });

  final LessonTestCubit cubit;
  final LessonTestState state;
  final TestQuestionModel question;

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
          answer: answer,
          onSelect: cubit.selectOption,
        );

      case TestQuestionType.fillBlanks:
        return TestFillBlanksQuestion(
          question: question,
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
          answer: answer,
          selectedBlankId: state.selectedBlankId,
          onBlankTap: cubit.selectBlank,
          onTyped: cubit.typeBlank,
        );

      case TestQuestionType.matchPairs:
        return TestMatchPairsQuestion(
          question: question,
          answer: answer,
          matchOrder: state.matchOrderOf(question.id),
          selectedPromptId: state.selectedPromptId,
          onPromptTap: (String pairId) => answer.matchOf(pairId) == null
              ? cubit.selectPrompt(pairId)
              : cubit.clearPair(pairId),
          onMatchTap: cubit.linkMatch,
        );

      case TestQuestionType.orderSentences:
        return TestOrderSentencesQuestion(
          question: question,
          answer: answer,
          onReorder: cubit.reorderSentences,
        );
    }
  }
}
