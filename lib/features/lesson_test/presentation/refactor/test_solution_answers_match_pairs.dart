part of 'test_solution_answers.dart';

List<String> _matchPairs(
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
