part of 'test_solution_answers.dart';

List<String> _trueFalse(
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
    return <String>[parsed ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr()];
  }

  final String text = _valueText(value);
  if (text.isNotEmpty) return <String>[text];

  return const <String>[];
}

bool? _inferBoolean(QuizQuestionResultModel result) {
  final bool? given = _asBool(
    result.givenAnswer['boolean'] ??
        result.givenAnswer['selected_boolean'] ??
        result.givenAnswer['answer'],
  );
  final bool? correct = result.isCorrect;
  if (given == null || correct == null) return null;

  return correct ? given : !given;
}

bool? _asBool(Object? value) {
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
