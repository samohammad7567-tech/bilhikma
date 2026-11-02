import '../../../../core/enums/test_question_type_enum.dart';
import 'test_blank_model.dart';
import 'test_match_item_model.dart';
import 'test_question_model.dart';

class AnswerValidationException implements Exception {
  const AnswerValidationException(this.key);

  final String key;

  @override
  String toString() => 'AnswerValidationException($key)';
}

class TestAnswerModel {
  const TestAnswerModel({
    this.optionIds = const <String>[],
    this.boolean,
    this.blanks = const <String, String>{},
    this.matches = const <String, String>{},
    this.order = const <String>[],
  });

  final List<String> optionIds;
  final bool? boolean;
  final Map<String, String> blanks;

  /// right item id -> left item id
  final Map<String, String> matches;

  final List<String> order;

  String? blankValue(String blankId) => blanks[blankId];

  String? leftForRight(String rightId) => matches[rightId];

  bool usesOption(String optionId) =>
      optionIds.contains(optionId) || blanks.containsValue(optionId);

  TestAnswerModel copyWith({
    List<String>? optionIds,
    bool? boolean,
    bool clearBoolean = false,
    Map<String, String>? blanks,
    Map<String, String>? matches,
    List<String>? order,
  }) => TestAnswerModel(
    optionIds: optionIds ?? this.optionIds,
    boolean: clearBoolean ? null : boolean ?? this.boolean,
    blanks: blanks ?? this.blanks,
    matches: matches ?? this.matches,
    order: order ?? this.order,
  );

  bool isAnswered(TestQuestionType type) => switch (type) {
    TestQuestionType.singleChoice => optionIds.length == 1,
    TestQuestionType.multiChoice => optionIds.isNotEmpty,
    TestQuestionType.trueFalse => boolean != null,
    TestQuestionType.fillBlanks ||
    TestQuestionType.typedBlanks => blanks.isNotEmpty,
    TestQuestionType.matchPairs => matches.isNotEmpty,
    TestQuestionType.orderSentences => order.isNotEmpty,
    TestQuestionType.mostCorrect => optionIds.length == 1,
  };

  void validateFor(TestQuestionModel question) {
    final TestQuestionType type = question.type;

    switch (type) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.mostCorrect:
        _validateChoice(question, exact: 1);
      case TestQuestionType.multiChoice:
        _validateChoice(question, max: question.effectiveMaxSelections);
      case TestQuestionType.trueFalse:
        if (boolean == null) {
          throw const AnswerValidationException('missing_boolean');
        }
      case TestQuestionType.fillBlanks:
        _validateBlanks(question, choices: true);
      case TestQuestionType.typedBlanks:
        _validateBlanks(question, choices: false);
      case TestQuestionType.matchPairs:
        _validateMatches(question);
      case TestQuestionType.orderSentences:
        _validateOrder(question);
    }
  }

  Map<String, dynamic> toSubmissionJson(TestQuestionModel question) {
    validateFor(question);

    return switch (question.type) {
      TestQuestionType.singleChoice || TestQuestionType.mostCorrect =>
        <String, dynamic>{'option_id': optionIds.single},
      TestQuestionType.multiChoice => <String, dynamic>{
        'option_ids': List<String>.of(optionIds),
      },
      TestQuestionType.trueFalse => <String, dynamic>{'boolean': boolean},
      TestQuestionType.fillBlanks || TestQuestionType.typedBlanks =>
        <String, dynamic>{'blanks': Map<String, String>.of(blanks)},
      TestQuestionType.matchPairs => <String, dynamic>{
        'matches': Map<String, String>.of(matches),
      },
      TestQuestionType.orderSentences => <String, dynamic>{
        'order': List<String>.of(order),
      },
    };
  }

  void _validateChoice(TestQuestionModel question, {int? exact, int? max}) {
    final Set<String> validIds = question.options
        .map((option) => option.id)
        .toSet();

    if (optionIds.toSet().length != optionIds.length) {
      throw const AnswerValidationException('duplicate_option_ids');
    }
    if (optionIds.any((String id) => !validIds.contains(id))) {
      throw const AnswerValidationException('unknown_option_id');
    }
    if (exact != null && optionIds.length != exact) {
      throw const AnswerValidationException('invalid_option_count');
    }
    if (max != null && (optionIds.isEmpty || optionIds.length > max)) {
      throw const AnswerValidationException('invalid_option_count');
    }
  }

  void _validateBlanks(TestQuestionModel question, {required bool choices}) {
    final Map<String, TestBlankModel> validBlanks = <String, TestBlankModel>{
      for (final TestBlankModel blank in question.blanks) blank.id: blank,
    };

    if (blanks.isEmpty) {
      throw const AnswerValidationException('missing_blanks');
    }

    for (final MapEntry<String, String> entry in blanks.entries) {
      final TestBlankModel? blank = validBlanks[entry.key];
      if (blank == null) {
        throw const AnswerValidationException('unknown_blank_id');
      }
      if (entry.value.trim().isEmpty) {
        throw const AnswerValidationException('empty_blank_value');
      }
      if (choices && blank.choices.isNotEmpty) {
        final bool valid = blank.choices.any(
          (choice) => choice.id == entry.value,
        );
        if (!valid) {
          throw const AnswerValidationException('unknown_blank_choice');
        }
      }
      if (!choices &&
          blank.maxLength != null &&
          entry.value.length > blank.maxLength!) {
        throw const AnswerValidationException('blank_answer_too_long');
      }
    }
  }

  void _validateMatches(TestQuestionModel question) {
    final Set<String> rightIds = question.rightItems
        .map((TestMatchItemModel item) => item.id)
        .toSet();
    final Set<String> leftIds = question.leftItems
        .map((TestMatchItemModel item) => item.id)
        .toSet();

    if (matches.isEmpty) {
      throw const AnswerValidationException('missing_matches');
    }
    if (matches.keys.any((String id) => !rightIds.contains(id))) {
      throw const AnswerValidationException('unknown_right_item_id');
    }
    if (matches.values.any((String id) => !leftIds.contains(id))) {
      throw const AnswerValidationException('unknown_left_item_id');
    }
    if (!question.allowsOneToManyMatching &&
        matches.values.toSet().length != matches.values.length) {
      throw const AnswerValidationException('duplicate_left_item_id');
    }
  }

  void _validateOrder(TestQuestionModel question) {
    final Set<String> validIds = question.sentences
        .map((sentence) => sentence.id)
        .toSet();

    if (order.length != question.sentences.length) {
      throw const AnswerValidationException('invalid_order_length');
    }
    if (order.any((String id) => !validIds.contains(id))) {
      throw const AnswerValidationException('unknown_order_item_id');
    }
    if (order.toSet().length != order.length) {
      throw const AnswerValidationException('duplicate_order_item_id');
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'option_ids': optionIds,
    'boolean': boolean,
    'blanks': blanks,
    'matches': matches,
    'order': order,
  };
}
