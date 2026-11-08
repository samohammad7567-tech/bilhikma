part of 'test_solution_answers.dart';

List<QuizReviewAnswer> _solutionMatchItems(
  Map<Object?, Object?> details,
  QuizQuestionResultModel result,
  TestQuestionModel? question,
) {
  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];
  final Set<String> seen = <String>{};

  void add(String left, String right, String? image) {
    if (left.trim().isEmpty || right.trim().isEmpty) return;

    final String text = '${left.trim()} → ${right.trim()}';
    if (!seen.add(text)) return;

    items.add(
      QuizReviewAnswer(
        text: text,
        imageUrl: image == null || image.trim().isEmpty ? null : image,
      ),
    );
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
        _solutionPairImage(pair, question),
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

  if (items.isEmpty && matches is Map) {
    for (final MapEntry<Object?, Object?> entry in matches.entries) {
      final String leftId = _valueText(entry.value);
      final String rightId = _valueText(entry.key);

      add(
        _resolve(leftId, question: question, left: true),
        _resolve(rightId, question: question, left: false),
        _matchItem(question, rightId, left: false)?.imageUrl ??
            _matchItem(question, leftId, left: true)?.imageUrl,
      );
    }
  }

  if (items.isEmpty) {
    for (final MapEntry<String, dynamic> entry
        in result.componentResults.entries) {
      final Object? value = entry.value;
      if (value is! Map) continue;

      add(
        _pairText(value, _leftKeys, question: question, left: true),
        _pairText(value, _rightKeys, question: question, left: false),
        _solutionPairImage(value, question),
      );
    }
  }

  return items;
}

String? _solutionPairImage(Map pair, TestQuestionModel? question) {
  final String? inline = MediaUrl.resolve(
    _stringOf(
      pair['right_image_path'] ??
          pair['right_image'] ??
          pair['target_image_path'] ??
          pair['target_image'] ??
          pair['left_image_path'] ??
          pair['left_image'] ??
          pair['source_image_path'] ??
          pair['source_image'],
    ),
  );
  if (inline != null && inline.trim().isNotEmpty) return inline;

  final String leftId = _idOf(pair['left_id']);
  final String rightId = _idOf(pair['right_id']);

  return _matchItem(question, rightId, left: false)?.imageUrl ??
      _matchItem(question, leftId, left: true)?.imageUrl;
}

TestMatchItemModel? _matchItem(
  TestQuestionModel? question,
  String id, {
  required bool left,
}) {
  if (question == null || id.isEmpty) return null;

  if (left) return question.leftById(id);
  return question.rightById(id);
}
