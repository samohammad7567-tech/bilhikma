part of 'test_solution_answers.dart';

const List<String> _leftKeys = <String>[
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

const List<String> _rightKeys = <String>[
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

String _pairText(
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

String _resolve(
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
