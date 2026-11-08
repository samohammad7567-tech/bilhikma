import 'package:easy_localization/easy_localization.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/media_url.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_blank_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_sentence_model.dart';
import 'quiz_review_answer.dart';
part 'test_solution_answers_blanks.dart';
part 'test_solution_answers_labels.dart';
part 'test_solution_answers_match.dart';
part 'test_solution_answers_match_keys.dart';
part 'test_solution_answers_match_pairs.dart';
part 'test_solution_answers_options.dart';
part 'test_solution_answers_order.dart';
part 'test_solution_answers_support.dart';
part 'test_solution_answers_true_false.dart';
class TestSolutionAnswers {
  TestSolutionAnswers._();

  static List<String> of(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final Map<Object?, Object?> details = _details(result);

    switch (result.questionType) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.multiChoice:
      case TestQuestionType.mostCorrect:
        final List<String> correct = _correctOptions(
          _read(details, result, <String>['options']),
          question: question,
        );
        if (correct.isNotEmpty) return correct;

        return _correctOptions(
          _read(details, result, <String>[
            'correct_options',
            'correct_option_ids',
            'correct_option_id',
            'correct_option',
            'correct_answers',
          ]),
          question: question,
          assumeAll: true,
        );

      case TestQuestionType.trueFalse:
        return _trueFalse(details, result);

      case TestQuestionType.fillBlanks:
        return _correctBlanks(
          _read(details, result, <String>['blanks', 'correct_blanks']),
          dropdown: true,
          question: question,
        );

      case TestQuestionType.typedBlanks:
        return _correctBlanks(
          _read(details, result, <String>['blanks', 'correct_blanks']),
          dropdown: false,
          question: question,
        );

      case TestQuestionType.orderSentences:
        return _texts(
          _read(details, result, <String>[
            'items',
            'correct_order',
            'correct_items',
            'order',
          ]),
          question: question,
        );

      case TestQuestionType.matchPairs:
        return _matchPairs(details, result, question);
    }
  }

  static List<QuizReviewAnswer> itemsOf(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final Map<Object?, Object?> details = _details(result);

    switch (result.questionType) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.multiChoice:
      case TestQuestionType.mostCorrect:
        final List<QuizReviewAnswer> correct = _correctOptionItems(
          _read(details, result, <String>['options']),
          question: question,
        );
        if (correct.isNotEmpty) return correct;

        return _correctOptionItems(
          _read(details, result, <String>[
            'correct_options',
            'correct_option_ids',
            'correct_option_id',
            'correct_option',
            'correct_answers',
          ]),
          question: question,
          assumeAll: true,
        );

      case TestQuestionType.trueFalse:
        return _textItems(_trueFalse(details, result));

      case TestQuestionType.fillBlanks:
        return _textItems(
          _correctBlanks(
            _read(details, result, <String>['blanks', 'correct_blanks']),
            dropdown: true,
            question: question,
          ),
        );

      case TestQuestionType.typedBlanks:
        return _textItems(
          _correctBlanks(
            _read(details, result, <String>['blanks', 'correct_blanks']),
            dropdown: false,
            question: question,
          ),
        );

      case TestQuestionType.orderSentences:
        return _orderedItems(
          _read(details, result, <String>[
            'items',
            'correct_order',
            'correct_items',
            'order',
          ]),
          question: question,
        );

      case TestQuestionType.matchPairs:
        return _solutionMatchItems(details, result, question);
    }
  }
}
