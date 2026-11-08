part of 'test_given_answers.dart';

List<String> _blanks(
  QuizQuestionResultModel result,
  Map<String, dynamic> given,
  TestQuestionModel? question,
) {
  final Object? raw = given['blanks'];
  final Map<Object?, Object?> map = <Object?, Object?>{
    if (raw is Map) ...Map<Object?, Object?>.from(raw),
  };

  for (final MapEntry<String, dynamic> entry in given.entries) {
    if (entry.key == 'blanks' || entry.value == null) continue;
    if (question == null || question.blankById(entry.key) != null) {
      map.putIfAbsent(entry.key, () => entry.value);
    }
  }

  for (final MapEntry<String, dynamic> entry in result.blankResults.entries) {
    map.putIfAbsent(entry.key, () => entry.value);
  }

  final List<String> values = <String>[];
  final Set<Object?> consumed = <Object?>{};

  if (question != null && question.blanks.isNotEmpty) {
    for (final blank in question.blanks) {
      final Object? value = map[blank.id] ?? given[blank.id];
      if (value == null) continue;

      consumed.add(blank.id);
      final String text = _blankLabel(question, blank.id, value);
      if (text.isNotEmpty) values.add(text);
    }
    if (values.isNotEmpty) return values;
  }

  for (final MapEntry<Object?, Object?> entry in map.entries) {
    if (consumed.contains(entry.key)) continue;

    final String text = _blankLabel(question, '${entry.key}', entry.value);
    if (text.isNotEmpty) values.add(text);
  }

  return values;
}

String _blankLabel(
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
        raw['selected_choice_id'] ??
        raw['choice_id'] ??
        raw['correct_choice_id'] ??
        raw['id'];
  }
  if (raw == null) return '';

  final String text = '$raw'.trim();
  if (text.isEmpty) return '';

  if (question != null) {
    for (final choice in question.blankById(blankId)?.choices ?? const []) {
      if (choice.id == text) return choice.label;
    }
    for (final choice in question.wordBank) {
      if (choice.id == text) return choice.label;
    }
    for (final choice in question.options) {
      if (choice.id == text) return choice.label;
    }
  }

  return text;
}
