part of 'test_solution_answers.dart';

Map<Object?, Object?> _details(QuizQuestionResultModel result) {
  final Map<String, dynamic>? solution = result.solution;
  if (solution == null) return const <Object?, Object?>{};

  final Object? details = solution['details'];
  if (details is Map) return details;

  return solution;
}

Object? _read(
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

String? _stringOf(Object? value) {
  if (value == null) return null;
  if (value is Map || value is List) return null;

  final String text = '$value'.trim();
  return text.isEmpty ? null : text;
}

String _idOf(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    return _idOf(value['id'] ?? value['text'] ?? value['label']);
  }
  if (value is List) return '';

  return '$value'.trim();
}

String _valueText(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    return _valueText(value['text'] ?? value['label'] ?? value['id']);
  }
  if (value is List) return '';

  return '$value'.trim();
}

bool _truthy(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final String text = '$value'.trim().toLowerCase();
  return text == 'true' || text == '1';
}

List<String> _unique(Iterable<String> values) {
  final Set<String> seen = <String>{};
  final List<String> result = <String>[];

  for (final String value in values) {
    final String text = value.trim();
    if (text.isEmpty || !seen.add(text)) continue;
    result.add(text);
  }

  return result;
}

List<QuizReviewAnswer> _textItems(Iterable<String> values) => values
    .map((String text) => QuizReviewAnswer(text: text.trim()))
    .where((QuizReviewAnswer answer) => !answer.isEmpty)
    .toList(growable: false);
