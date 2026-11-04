import 'dart:convert';

import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_option_model.dart';
import '../../data/models/test_question_model.dart';

class TestReviewPrompt {
  TestReviewPrompt._();

  static final RegExp _placeholder = RegExp(r'\{\{([^{}]+)\}\}');
  static const String _blankMarker = '__________';

  static String of({
    required QuizQuestionResultModel result,
    required TestQuestionModel? question,
  }) {
    if (question == null) return '';

    final String prompt = question.prompt.trim();
    if (!question.isBlankQuestion) return prompt;

    final String template = (question.body ?? prompt).trim();
    if (template.isEmpty) return prompt;

    return template.replaceAllMapped(_placeholder, (Match match) {
      final String blankId = match.group(1)!.trim();
      final String? value = _givenValue(result, question, blankId);

      return value == null ? _blankMarker : const HtmlEscape().convert(value);
    });
  }

  static String? _givenValue(
    QuizQuestionResultModel result,
    TestQuestionModel question,
    String blankId,
  ) {
    final Object? blanks = result.givenAnswer['blanks'];
    Object? raw = blanks is Map ? blanks[blankId] : result.givenAnswer[blankId];

    raw ??= _blankResult(result.blankResults[blankId]);
    if (raw is Map) {
      raw =
          raw['value'] ??
          raw['text'] ??
          raw['answer_text'] ??
          raw['given_answer'] ??
          raw['id'];
    }
    if (raw == null) return null;

    final String value = '$raw'.trim();
    if (value.isEmpty) return null;

    return _labelFor(question, blankId, value);
  }

  static Object? _blankResult(Object? value) {
    if (value is! Map) return null;

    return value['given_answer'] ??
        value['value'] ??
        value['text'] ??
        value['answer_text'];
  }

  static String _labelFor(
    TestQuestionModel question,
    String blankId,
    String value,
  ) {
    final List<TestOptionModel> options = <TestOptionModel>[
      ...?question.blankById(blankId)?.choices,
      ...question.options,
      ...question.wordBank,
    ];

    for (final TestOptionModel option in options) {
      if (option.id == value) return option.label;
    }

    return value;
  }
}
