part of 'test_given_answers.dart';

List<QuizReviewAnswer> _matchItems(
  Object? value,
  TestQuestionModel? question,
  QuizQuestionResultModel result,
) {
  final List<QuizReviewAnswer> items = _matchItemList(value, question);
  if (items.isNotEmpty) return items;

  return _matchItemList(result.componentResults, question);
}

List<QuizReviewAnswer> _matchItemList(
  Object? value,
  TestQuestionModel? question,
) {
  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];

  void add(String left, String right, String? image) {
    if (left.trim().isEmpty || right.trim().isEmpty) return;

    final String text = '${left.trim()} → ${right.trim()}';
    if (items.any((QuizReviewAnswer item) => item.text == text)) return;

    items.add(
      QuizReviewAnswer(
        text: text,
        imageUrl: image == null || image.trim().isEmpty ? null : image,
      ),
    );
  }

  if (value is Map) {
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.value is Map && _hasPairKeys(entry.value as Map)) {
        final Map pair = entry.value as Map;
        add(
          _pairText(pair, question, left: true),
          _pairText(pair, question, left: false),
          _pairImage(pair, question),
        );
        continue;
      }

      final String leftId = _idOf(entry.value);
      final String rightId = _idOf(entry.key);

      add(
        _matchText(leftId, question, left: true),
        _matchText(rightId, question, left: false),
        _match(question, rightId, left: false)?.imageUrl ??
            _match(question, leftId, left: true)?.imageUrl,
      );
    }

    return items;
  }

  if (value is List) {
    for (final Map pair in value.whereType<Map>()) {
      add(
        _pairText(pair, question, left: true),
        _pairText(pair, question, left: false),
        _pairImage(pair, question),
      );
    }
  }

  return items;
}

List<String> _matches(
  Object? value,
  TestQuestionModel? question,
  QuizQuestionResultModel result,
) {
  final List<String> pairs = _matchPairs(value, question);
  if (pairs.isNotEmpty) return pairs;

  return _matchPairs(result.componentResults, question);
}

List<String> _matchPairs(Object? value, TestQuestionModel? question) {
  final List<String> pairs = <String>[];

  void add(String left, String right) {
    if (left.trim().isEmpty || right.trim().isEmpty) return;

    final String entry = '$left → $right';
    if (!pairs.contains(entry)) pairs.add(entry);
  }

  if (value is Map) {
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.value is Map && _hasPairKeys(entry.value as Map)) {
        final Map pair = entry.value as Map;
        add(
          _pairText(pair, question, left: true),
          _pairText(pair, question, left: false),
        );
        continue;
      }

      add(
        _matchText(_idOf(entry.value), question, left: true),
        _matchText(_idOf(entry.key), question, left: false),
      );
    }

    return pairs;
  }

  if (value is List) {
    for (final Map pair in value.whereType<Map>()) {
      add(
        _pairText(pair, question, left: true),
        _pairText(pair, question, left: false),
      );
    }
  }

  return pairs;
}

bool _hasPairKeys(Map pair) {
  const List<String> keys = <String>[
    'left_id',
    'right_id',
    'left',
    'right',
    'left_text',
    'right_text',
    'source',
    'target',
  ];

  return keys.any(pair.containsKey);
}
