import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_blank_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_sentence_model.dart';

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

  static Object? _read(
    Map<Object?, Object?> details,
    QuizQuestionResultModel result,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final Object? value = details[key];
      if (value != null) return value;
    }

    final Map<String, dynamic>? solution = result.solution;
    if (solution != null) {
      for (final String key in keys) {
        final Object? value = solution[key];
        if (value != null) return value;
      }
    }

    return null;
  }

  static Map<Object?, Object?> _details(QuizQuestionResultModel result) {
    final Map<String, dynamic>? solution = result.solution;
    if (solution == null) return const <Object?, Object?>{};

    final Object? details = solution['details'];
    if (details is Map) return details;

    return solution;
  }

  static List<String> _correctOptions(
    Object? value, {
    TestQuestionModel? question,
    bool assumeAll = false,
  }) {
    final List<String> texts = <String>[];

    void add(Object? item) {
      if (item == null) return;

      if (item is Map) {
        final bool isCorrect =
            _truthy(item['is_correct']) || _truthy(item['correct']);
        if (!isCorrect && !assumeAll) return;

        final String id = _idOf(item);
        final Object? text =
            item['text'] ??
            item['label'] ??
            item['option_text'] ??
            _optionLabel(question, id);
        if (text != null && '$text'.trim().isNotEmpty) texts.add('$text');
        return;
      }

      final String id = _idOf(item);
      if (id.isEmpty) return;
      texts.add(_optionLabel(question, id) ?? id);
    }

    if (value is List) {
      value.forEach(add);
    } else if (value is Map) {
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        if (entry.value is Map) {
          final Map<Object?, Object?> map = Map<Object?, Object?>.from(
            entry.value as Map,
          );
          map['id'] ??= entry.key;
          add(map);
        } else {
          add(entry.value);
        }
      }
    } else {
      add(value);
    }

    return _unique(texts);
  }

  static List<String> _trueFalse(
    Map<Object?, Object?> details,
    QuizQuestionResultModel result,
  ) {
    final Object? value = _read(details, result, <String>[
      'correct_answer',
      'answer',
      'value',
      'correct',
      'boolean',
      'is_correct',
    ]);

    final bool? parsed =
        _asBool(value) ?? result.correctBoolean ?? _inferBoolean(result);
    if (parsed != null) {
      return <String>[
        parsed ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr(),
      ];
    }

    final String text = _valueText(value);
    if (text.isNotEmpty) return <String>[text];

    return const <String>[];
  }

  static bool? _inferBoolean(QuizQuestionResultModel result) {
    final bool? given = _asBool(
      result.givenAnswer['boolean'] ??
          result.givenAnswer['selected_boolean'] ??
          result.givenAnswer['answer'],
    );
    final bool? correct = result.isCorrect;
    if (given == null || correct == null) return null;

    return correct ? given : !given;
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

  static List<String> _correctBlanks(
    Object? value, {
    required bool dropdown,
    TestQuestionModel? question,
  }) {
    final List<Map> items = <Map>[];
    final List<String> texts = <String>[];

    if (value is List) {
      for (final Object? item in value) {
        if (item is Map) {
          items.add(item);
        } else if (item != null) {
          if (dropdown) {
            texts.addAll(
              _correctOptions(item, question: question, assumeAll: true),
            );
          } else {
            texts.addAll(_accepted(item));
          }
        }
      }
    } else if (value is Map) {
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        if (entry.value is Map) {
          final Map<Object?, Object?> map = Map<Object?, Object?>.from(
            entry.value as Map,
          );
          map['id'] ??= entry.key;
          items.add(map);
        } else if (entry.value != null) {
          final Map<Object?, Object?> map = <Object?, Object?>{'id': entry.key};
          if (dropdown) {
            map['correct_choice_id'] = entry.value;
          } else {
            map['accepted'] = entry.value;
          }
          items.add(map);
        }
      }
    }

    for (final Map item in items) {
      if (dropdown) {
        final Object? choices = item['choices'] ?? item['options'];
        texts.addAll(_correctOptions(choices, question: question));

        final Object? direct =
            item['correct_choice_id'] ??
            item['correct_choice'] ??
            item['correct_option_id'] ??
            item['correct_answer'];
        if (direct != null) {
          texts.addAll(
            _correctOptions(direct, question: question, assumeAll: true),
          );
        }
        continue;
      }

      final Object? accepted =
          item['accepted'] ??
          item['accepted_answers'] ??
          item['correct_answers'] ??
          item['answers'] ??
          item['correct_answer'] ??
          item['answer_text'];
      texts.addAll(_accepted(accepted));
    }

    return _unique(texts);
  }

  static List<String> _accepted(Object? value) {
    if (value is Map) {
      return _accepted(value['answer_text'] ?? value['text'] ?? value['value']);
    }

    if (value is List) {
      final List<String> forms = <String>[];
      String? primary;

      for (final Object? item in value) {
        if (item is Map) {
          final Object? text =
              item['answer_text'] ?? item['text'] ?? item['value'];
          if (text == null || '$text'.trim().isEmpty) continue;

          forms.add('$text');
          if (item['is_primary'] == true) primary ??= '$text';
          continue;
        }

        if (item == null || '$item'.trim().isEmpty) continue;
        forms.add('$item');
      }

      return <String>[if (primary != null) primary else ...forms];
    }

    if (value != null && '$value'.trim().isNotEmpty) {
      return <String>['$value'];
    }

    return const <String>[];
  }

  static List<String> _texts(Object? value, {TestQuestionModel? question}) {
    if (value is! List) return const <String>[];

    final List<String> texts = <String>[];

    for (final Object? item in value) {
      if (item is Map) {
        final Object? text = item['text'] ?? item['label'];
        final String resolved = text != null
            ? '$text'
            : _sentenceText(question, _idOf(item)) ?? _idOf(item);
        if (resolved.trim().isNotEmpty) texts.add(resolved);
        continue;
      }

      final String id = _idOf(item);
      final String text = _sentenceText(question, id) ?? id;
      if (text.trim().isNotEmpty) texts.add(text);
    }

    return _unique(texts);
  }

  static List<String> _matchPairs(
    Map<Object?, Object?> details,
    QuizQuestionResultModel result,
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
      details['correct_pairs'],
      details['correct_matches'],
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
        (details['pairs'] is Map ? details['pairs'] : null) ??
        (details['matches'] is Map ? details['matches'] : null) ??
        (details['matching'] is Map ? details['matching'] : null) ??
        (details['correct_matches'] is Map ? details['correct_matches'] : null);
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
      for (final MapEntry<String, dynamic> entry
          in result.componentResults.entries) {
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
    'left_item_text',
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
    'right_item_text',
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

  static String? _optionLabel(TestQuestionModel? question, String id) {
    if (question == null || id.isEmpty) return null;

    final String? option = question.optionById(id)?.label;
    if (option != null && option.trim().isNotEmpty) return option;

    for (final TestOptionModel word in question.wordBank) {
      if (word.id == id) return word.label;
    }

    for (final TestBlankModel blank in question.blanks) {
      for (final TestOptionModel choice in blank.choices) {
        if (choice.id == id) return choice.label;
      }
    }

    return null;
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

  static bool _truthy(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final String text = '$value'.trim().toLowerCase();
    return text == 'true' || text == '1';
  }

  static List<String> _unique(Iterable<String> values) {
    final Set<String> seen = <String>{};
    final List<String> result = <String>[];

    for (final String value in values) {
      final String text = value.trim();
      if (text.isEmpty || !seen.add(text)) continue;
      result.add(text);
    }

    return result;
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
