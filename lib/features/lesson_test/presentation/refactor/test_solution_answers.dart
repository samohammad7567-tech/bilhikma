import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';

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
        return _correctOptions(
          details['options'] ?? details['correct_options'],
        );

      case TestQuestionType.trueFalse:
        return _trueFalse(details);

      case TestQuestionType.fillBlanks:
        return _correctBlanks(details['blanks'], dropdown: true);

      case TestQuestionType.typedBlanks:
        return _correctBlanks(details['blanks'], dropdown: false);

      case TestQuestionType.orderSentences:
        return _texts(details['items'] ?? details['correct_order']);

      case TestQuestionType.matchPairs:
        return _matchPairs(details, result.componentResults, question);
    }
  }

  static Map<Object?, Object?> _details(QuizQuestionResultModel result) {
    final Map<String, dynamic>? solution = result.solution;
    if (solution == null) return const <Object?, Object?>{};

    final Object? details = solution['details'];
    if (details is Map) return details;

    return solution;
  }

  static List<String> _correctOptions(Object? value) {
    if (value is! List) return const <String>[];

    return value
        .whereType<Map>()
        .where((Map item) => item['is_correct'] == true)
        .map((Map item) => item['text'] ?? item['label'])
        .whereType<Object>()
        .map((Object text) => '$text')
        .toList(growable: false);
  }

  static List<String> _trueFalse(Map<Object?, Object?> details) {
    final Object? value =
        details['correct_answer'] ??
        details['answer'] ??
        details['value'] ??
        details['correct'] ??
        details['is_correct'];

    final bool? parsed = _asBool(value);
    if (parsed != null) {
      return <String>[
        parsed ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr(),
      ];
    }

    final String text = _valueText(value);
    if (text.isNotEmpty) return <String>[text];

    return const <String>[];
  }

  static bool? _asBool(Object? value) {
    if (value is bool) return value;
    if (value == null) return null;

    final String text = '$value'.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'صح' || text == 'صحيح') {
      return true;
    }
    if (text == 'false' || text == '0' || text == 'خطأ' || text == 'خطا') {
      return false;
    }

    return null;
  }

  static List<String> _correctBlanks(Object? value, {required bool dropdown}) {
    if (value is! List) return const <String>[];

    final List<String> texts = <String>[];

    for (final Map item in value.whereType<Map>()) {
      if (dropdown) {
        texts.addAll(_correctOptions(item['choices']));
      } else {
        texts.addAll(_primaryAccepted(item['accepted']));
      }
    }

    return texts;
  }

  static List<String> _primaryAccepted(Object? value) {
    if (value is! List) return const <String>[];

    final List<String> forms = <String>[];
    String? primary;

    for (final Map item in value.whereType<Map>()) {
      final Object? text = item['answer_text'];
      if (text == null) continue;

      forms.add('$text');
      if (item['is_primary'] == true) primary ??= '$text';
    }

    return <String>[if (primary != null) primary else ...forms];
  }

  static List<String> _texts(Object? value) {
    if (value is! List) return const <String>[];

    return value
        .map(
          (Object? item) => item is Map ? item['text'] ?? item['label'] : item,
        )
        .whereType<Object>()
        .map((Object text) => '$text')
        .where((String text) => text.trim().isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _matchPairs(
    Map<Object?, Object?> details,
    Map<String, dynamic> componentResults,
    TestQuestionModel? question,
  ) {
    final List<String> answers = <String>[];
    final Set<String> seen = <String>{};

    void add(String left, String right) {
      final String entry = '${left.trim()} → ${right.trim()}';
      if (left.trim().isEmpty || right.trim().isEmpty) return;
      if (seen.add(entry)) answers.add(entry);
    }

    for (final Object? pairs in <Object?>[
      details['pairs'],
      details['matches'],
      details['matching'],
      details['items'],
    ]) {
      if (pairs is! List) continue;

      for (final Map pair in pairs.whereType<Map>()) {
        add(
          _pairText(pair, _leftKeys, question: question, left: true),
          _pairText(pair, _rightKeys, question: question, left: false),
        );
      }
    }

    final Object? matches =
        details['pairs_map'] ??
        details['map'] ??
        (details['pairs'] is Map ? details['pairs'] : null);
    if (answers.isEmpty && matches is Map) {
      for (final MapEntry<Object?, Object?> entry in matches.entries) {
        final String left = _resolve(
          entry.value,
          question: question,
          left: true,
        );
        final String right = _resolve(
          entry.key,
          question: question,
          left: false,
        );
        add(left, right);
      }
    }

    if (answers.isEmpty) {
      for (final MapEntry<String, dynamic> entry in componentResults.entries) {
        final Object? value = entry.value;
        if (value is Map) {
          add(
            _pairText(value, _leftKeys, question: question, left: true),
            _pairText(value, _rightKeys, question: question, left: false),
          );
        }
      }
    }

    return answers;
  }

  static const List<String> _leftKeys = <String>[
    'left_text',
    'left_label',
    'left',
    'source_text',
    'source',
    'prompt',
    'left_item',
    'leftItem',
  ];

  static const List<String> _rightKeys = <String>[
    'right_text',
    'right_label',
    'right',
    'target_text',
    'target',
    'match',
    'right_item',
    'rightItem',
  ];

  static String _pairText(
    Map pair,
    List<String> keys, {
    required TestQuestionModel? question,
    required bool left,
  }) {
    for (final String key in keys) {
      final String text = _valueText(pair[key]);
      if (text.isNotEmpty) return text;
    }

    return _resolve(
      pair[left ? 'left_id' : 'right_id'],
      question: question,
      left: left,
    );
  }

  static String _resolve(
    Object? value, {
    required TestQuestionModel? question,
    required bool left,
  }) {
    final String text = _valueText(value);
    if (text.isEmpty || question == null) return text;

    final List<TestMatchItemModel> items = left
        ? question.leftItems
        : question.rightItems;

    for (final TestMatchItemModel item in items) {
      if (item.id == text) return item.text;
    }

    return text;
  }

  static String _valueText(Object? value) {
    if (value == null) return '';
    if (value is Map) {
      return _valueText(value['text'] ?? value['label'] ?? value['id']);
    }
    if (value is List) return '';

    return '$value'.trim();
  }
}
