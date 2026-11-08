import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/media_url.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_sentence_model.dart';
import 'quiz_review_answer.dart';

part 'test_given_answers_blanks.dart';
part 'test_given_answers_match.dart';
part 'test_given_answers_match_items.dart';
part 'test_given_answers_options.dart';
part 'test_given_answers_order.dart';

class TestGivenAnswers {
  TestGivenAnswers._();

  static List<String> of(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final Map<String, dynamic> given = result.givenAnswer;

    switch (result.questionType) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.mostCorrect:
        return _options(
          _first(given, <String>[
            'option_id',
            'option_ids',
            'selected_option_id',
          ]),
          question,
        );

      case TestQuestionType.multiChoice:
        return _options(
          _first(given, <String>[
            'option_ids',
            'selected_option_ids',
            'option_id',
          ]),
          question,
        );

      case TestQuestionType.trueFalse:
        return _trueFalse(
          _first(given, <String>[
            'boolean',
            'selected_boolean',
            'answer',
            'value',
          ]),
        );

      case TestQuestionType.fillBlanks:
      case TestQuestionType.typedBlanks:
        return _blanks(result, given, question);

      case TestQuestionType.orderSentences:
        return _order(
          _first(given, <String>['order', 'item_ids', 'ordered_ids']),
          question,
          result,
        );

      case TestQuestionType.matchPairs:
        return _matches(
          _first(given, <String>['matches', 'pairs', 'map']),
          question,
          result,
        );
    }
  }

  static List<QuizReviewAnswer> itemsOf(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final Map<String, dynamic> given = result.givenAnswer;

    switch (result.questionType) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.mostCorrect:
        return _optionItems(
          _first(given, <String>[
            'option_id',
            'option_ids',
            'selected_option_id',
          ]),
          question,
          result,
        );

      case TestQuestionType.multiChoice:
        return _optionItems(
          _first(given, <String>[
            'option_ids',
            'selected_option_ids',
            'option_id',
          ]),
          question,
          result,
        );

      case TestQuestionType.trueFalse:
        return _textItems(
          _trueFalse(
            _first(given, <String>[
              'boolean',
              'selected_boolean',
              'answer',
              'value',
            ]),
          ),
        );

      case TestQuestionType.fillBlanks:
      case TestQuestionType.typedBlanks:
        return _textItems(_blanks(result, given, question));

      case TestQuestionType.orderSentences:
        return _orderItems(
          _first(given, <String>['order', 'item_ids', 'ordered_ids']),
          question,
          result,
        );

      case TestQuestionType.matchPairs:
        return _matchItems(
          _first(given, <String>['matches', 'pairs', 'map']),
          question,
          result,
        );
    }
  }
}
