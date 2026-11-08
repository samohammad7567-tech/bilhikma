part of 'test_given_answers.dart';

String? _pairImage(Map pair, TestQuestionModel? question) {
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

  return _match(question, _idOf(pair['right_id']), left: false)?.imageUrl ??
      _match(question, _idOf(pair['left_id']), left: true)?.imageUrl;
}

TestMatchItemModel? _match(
  TestQuestionModel? question,
  String id, {
  required bool left,
}) {
  if (question == null || id.isEmpty) return null;

  final List<TestMatchItemModel> items = left
      ? question.leftItems
      : question.rightItems;

  for (final TestMatchItemModel item in items) {
    if (item.id == id) return item;
  }

  return null;
}

String _pairText(
  Map pair,
  TestQuestionModel? question, {
  required bool left,
}) {
  final List<String> textKeys = left
      ? <String>['left_text', 'left_label', 'left', 'source_text', 'source']
      : <String>[
          'right_text',
          'right_label',
          'right',
          'target_text',
          'target',
        ];

  for (final String key in textKeys) {
    final Object? value = pair[key];
    if (value != null && '$value'.trim().isNotEmpty) return '$value';
  }

  return _matchText(
    _idOf(pair[left ? 'left_id' : 'right_id']),
    question,
    left: left,
  );
}

String _matchText(
  String id,
  TestQuestionModel? question, {
  required bool left,
}) {
  if (id.isEmpty || question == null) return id;

  final List<TestMatchItemModel> items = left
      ? question.leftItems
      : question.rightItems;

  for (final TestMatchItemModel item in items) {
    if (item.id == id) return item.text;
  }

  return id;
}
