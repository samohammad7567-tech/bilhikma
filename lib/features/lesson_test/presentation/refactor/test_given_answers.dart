import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_sentence_model.dart';

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
        return _blanks(given, question);

      case TestQuestionType.orderSentences:
        return _order(
          _first(given, <String>['order', 'item_ids', 'ordered_ids']),
          question,
        );

      case TestQuestionType.matchPairs:
        return _matches(
          _first(given, <String>['matches', 'pairs', 'map']),
          question,
        );
    }
  }

  static Object? _first(Map<String, dynamic> given, List<String> keys) {
    for (final String key in keys) {
      final Object? value = given[key];
      if (value != null) return value;
    }
    return null;
  }

  static List<String> _options(Object? value, TestQuestionModel? question) {
    final List<String> ids = <String>[];

    if (value is List) {
      for (final Object? item in value) {
        final String id = _idOf(item);
        if (id.isNotEmpty) ids.add(id);
      }
    } else {
      final String id = _idOf(value);
      if (id.isNotEmpty) ids.add(id);
    }

    return ids
        .map((String id) => question?.optionById(id)?.label ?? id)
        .where((String text) => text.trim().isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _blanks(
    Map<String, dynamic> given,
    TestQuestionModel? question,
  ) {
    final Object? raw = given['blanks'];
    final Map<Object?, Object?> map = raw is Map
        ? Map<Object?, Object?>.from(raw)
        : <Object?, Object?>{};

    final List<String> values = <String>[];

    if (question != null && question.blanks.isNotEmpty) {
      for (final blank in question.blanks) {
        final String text = _blankLabel(
          question,
          blank.id,
          map[blank.id] ?? given[blank.id],
        );
        if (text.isNotEmpty) values.add(text);
      }
      if (values.isNotEmpty) return values;
    }

    for (final MapEntry<Object?, Object?> entry in map.entries) {
      final String text = _blankLabel(question, '${entry.key}', entry.value);
      if (text.isNotEmpty) values.add(text);
    }

    return values;
  }

  static String _blankLabel(
    TestQuestionModel? question,
    String blankId,
    Object? value,
  ) {
    Object? raw = value;
    if (raw is Map) {
      raw =
          raw['value'] ??
          raw['text'] ??
          raw['answer_text'] ??
          raw['given_answer'] ??
          raw['id'];
    }
    if (raw == null) return '';

    final String text = '$raw'.trim();
    if (text.isEmpty) return '';

    if (question != null) {
      for (final choice in question.blankById(blankId)?.choices ?? const []) {
        if (choice.id == text) return choice.label;
      }
    }

    return text;
  }

  static List<String> _trueFalse(Object? value) {
    if (value is bool) {
      return <String>[value ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr()];
    }

    final String text = '$value'.trim().toLowerCase();
    if (text == 'true' || text == '1') {
      return <String>[LangKeys.quizTrue.tr()];
    }
    if (text == 'false' || text == '0') {
      return <String>[LangKeys.quizFalse.tr()];
    }

    return const <String>[];
  }

  static List<String> _order(Object? value, TestQuestionModel? question) {
    if (value is! List) return const <String>[];

    final List<String> texts = <String>[];

    for (final Object? item in value) {
      if (item is Map) {
        final String id = _idOf(item);
        final Object? text = item['text'] ?? item['label'];
        final String resolved = text != null
            ? '$text'
            : _sentenceText(question, id) ?? id;
        if (resolved.trim().isNotEmpty) texts.add(resolved);
        continue;
      }

      final String id = _idOf(item);
      final String text = _sentenceText(question, id) ?? id;
      if (text.trim().isNotEmpty) texts.add(text);
    }

    return texts;
  }

  static List<String> _matches(Object? value, TestQuestionModel? question) {
    if (value is Map) {
      final List<String> pairs = <String>[];

      for (final MapEntry<Object?, Object?> entry in value.entries) {
        final String left = _matchText(
          _idOf(entry.value),
          question,
          left: true,
        );
        final String right = _matchText(
          _idOf(entry.key),
          question,
          left: false,
        );
        if (left.isNotEmpty && right.isNotEmpty) {
          pairs.add('$left → $right');
        }
      }

      return pairs;
    }

    if (value is List) {
      final List<String> pairs = <String>[];

      for (final Map pair in value.whereType<Map>()) {
        final String left = _pairText(pair, question, left: true);
        final String right = _pairText(pair, question, left: false);
        if (left.isNotEmpty && right.isNotEmpty) {
          pairs.add('$left → $right');
        }
      }

      return pairs;
    }

    return const <String>[];
  }

  static String _pairText(
    Map pair,
    TestQuestionModel? question, {
    required bool left,
  }) {
    final List<String> textKeys = left
        ? <String>['left_text', 'left_label', 'left', 'source_text', 'source']
        : <String>[
            'right_text',
            'right_label',
            'right',
            'target_text',
            'target',
          ];

    for (final String key in textKeys) {
      final Object? value = pair[key];
      if (value != null && '$value'.trim().isNotEmpty) return '$value';
    }

    return _matchText(
      _idOf(pair[left ? 'left_id' : 'right_id']),
      question,
      left: left,
    );
  }

  static String _matchText(
    String id,
    TestQuestionModel? question, {
    required bool left,
  }) {
    if (id.isEmpty || question == null) return id;

    final List<TestMatchItemModel> items = left
        ? question.leftItems
        : question.rightItems;

    for (final TestMatchItemModel item in items) {
      if (item.id == id) return item.text;
    }

    return id;
  }

  static String? _sentenceText(TestQuestionModel? question, String id) {
    if (question == null || id.isEmpty) return null;

    for (final TestSentenceModel sentence in question.sentences) {
      if (sentence.id == id) return sentence.text;
    }

    return null;
  }

  static String _idOf(Object? value) {
    if (value == null) return '';
    if (value is Map) {
      return _idOf(value['id'] ?? value['text'] ?? value['label']);
    }
    if (value is List) return '';

    return '$value'.trim();
  }
}
