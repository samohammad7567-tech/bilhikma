part of 'test_solution_answers.dart';

List<String> _correctBlanks(
  Object? value, {
  required bool dropdown,
  TestQuestionModel? question,
}) {
  final List<Map> items = <Map>[];
  final List<String> texts = <String>[];

  if (value is List) {
    for (final Object? item in value) {
      if (item is Map) {
        items.add(item);
      } else if (item != null) {
        if (dropdown) {
          texts.addAll(
            _correctOptions(item, question: question, assumeAll: true),
          );
        } else {
          texts.addAll(_accepted(item));
        }
      }
    }
  } else if (value is Map) {
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.value is Map) {
        final Map<Object?, Object?> map = Map<Object?, Object?>.from(
          entry.value as Map,
        );
        map['id'] ??= entry.key;
        items.add(map);
      } else if (entry.value != null) {
        final Map<Object?, Object?> map = <Object?, Object?>{'id': entry.key};
        if (dropdown) {
          map['correct_choice_id'] = entry.value;
        } else {
          map['accepted'] = entry.value;
        }
        items.add(map);
      }
    }
  }

  for (final Map item in items) {
    if (dropdown) {
      final Object? choices = item['choices'] ?? item['options'];
      texts.addAll(_correctOptions(choices, question: question));

      final Object? direct =
          item['correct_choice_id'] ??
          item['correct_choice'] ??
          item['correct_option_id'] ??
          item['correct_answer'];
      if (direct != null) {
        texts.addAll(
          _correctOptions(direct, question: question, assumeAll: true),
        );
      }
      continue;
    }

    final Object? accepted =
        item['accepted'] ??
        item['accepted_answers'] ??
        item['correct_answers'] ??
        item['answers'] ??
        item['correct_answer'] ??
        item['answer_text'];
    texts.addAll(_accepted(accepted));
  }

  return _unique(texts);
}

List<String> _accepted(Object? value) {
  if (value is Map) {
    return _accepted(value['answer_text'] ?? value['text'] ?? value['value']);
  }

  if (value is List) {
    final List<String> forms = <String>[];
    String? primary;

    for (final Object? item in value) {
      if (item is Map) {
        final Object? text =
            item['answer_text'] ?? item['text'] ?? item['value'];
        if (text == null || '$text'.trim().isEmpty) continue;

        forms.add('$text');
        if (item['is_primary'] == true) primary ??= '$text';
        continue;
      }

      if (item == null || '$item'.trim().isEmpty) continue;
      forms.add('$item');
    }

    return <String>[if (primary != null) primary else ...forms];
  }

  if (value != null && '$value'.trim().isNotEmpty) {
    return <String>['$value'];
  }

  return const <String>[];
}
