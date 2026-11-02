import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../data/models/quiz_question_result_model.dart';

class TestSolutionAnswers {
  TestSolutionAnswers._();

  static List<String> of(QuizQuestionResultModel result) {
    final Object? details = result.solution?['details'];
    if (details is! Map) return const <String>[];

    switch (result.questionType) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.multiChoice:
      case TestQuestionType.mostCorrect:
        return _correctOptions(details['options']);

      case TestQuestionType.trueFalse:
        final Object? value = details['correct_answer'];
        if (value is! bool) return const <String>[];
        return <String>[
          value ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr(),
        ];

      case TestQuestionType.fillBlanks:
        return _correctBlanks(details['blanks'], dropdown: true);

      case TestQuestionType.typedBlanks:
        return _correctBlanks(details['blanks'], dropdown: false);

      case TestQuestionType.orderSentences:
        return _texts(details['items']);

      case TestQuestionType.matchPairs:
        return const <String>[];
    }
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
        .whereType<Map>()
        .map((Map item) => item['text'] ?? item['label'])
        .whereType<Object>()
        .map((Object text) => '$text')
        .toList(growable: false);
  }
}
