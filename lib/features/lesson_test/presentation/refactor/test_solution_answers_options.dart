part of 'test_solution_answers.dart';

List<QuizReviewAnswer> _correctOptionItems(
  Object? value, {
  TestQuestionModel? question,
  bool assumeAll = false,
}) {
  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];
  final Set<String> seen = <String>{};

  void add(String? text, String? image, String? feedback) {
    final String resolvedText = text?.trim() ?? '';
    final String? resolvedImage = image == null || image.trim().isEmpty
        ? null
        : image.trim();
    final String? resolvedFeedback = _stringOf(feedback);

    if (resolvedText.isEmpty && resolvedImage == null) return;

    final String key = '$resolvedText|${resolvedImage ?? ''}';
    if (!seen.add(key)) return;

    items.add(
      QuizReviewAnswer(
        text: resolvedText,
        imageUrl: resolvedImage,
        feedback: resolvedFeedback,
      ),
    );
  }

  void addItem(Object? item) {
    if (item == null) return;

    if (item is Map) {
      final bool isCorrect =
          _truthy(item['is_correct']) || _truthy(item['correct']);
      if (!isCorrect && !assumeAll) return;

      final String id = _idOf(item);
      final String? text =
          _stringOf(
            item['text'] ?? item['label'] ?? item['option_text'] ?? item['answer'],
          ) ??
          _optionLabel(question, id) ??
          (id.isEmpty ? null : id);
      final String? image =
          MediaUrl.resolve(
            _stringOf(
              item['image_path'] ?? item['image'] ?? item['option_image_path'],
            ),
          ) ??
          _optionImage(question, id);
      final String? feedback = _stringOf(
        item['feedback'] ?? item['option_feedback'] ?? item['comment'],
      );

      add(text, image, feedback);
      return;
    }

    final String id = _idOf(item);
    if (id.isEmpty) return;

    add(_optionLabel(question, id) ?? id, _optionImage(question, id), null);
  }

  if (value is List) {
    value.forEach(addItem);
  } else if (value is Map) {
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.value is Map) {
        final Map<Object?, Object?> map = Map<Object?, Object?>.from(
          entry.value as Map,
        );
        map['id'] ??= entry.key;
        addItem(map);
      } else {
        addItem(entry.value);
      }
    }
  } else {
    addItem(value);
  }

  return items;
}

List<String> _correctOptions(
  Object? value, {
  TestQuestionModel? question,
  bool assumeAll = false,
}) {
  final List<String> texts = <String>[];

  void add(Object? item) {
    if (item == null) return;

    if (item is Map) {
      final bool isCorrect =
          _truthy(item['is_correct']) || _truthy(item['correct']);
      if (!isCorrect && !assumeAll) return;

      final String id = _idOf(item);
      final Object? text =
          item['text'] ??
          item['label'] ??
          item['option_text'] ??
          _optionLabel(question, id);
      if (text != null && '$text'.trim().isNotEmpty) texts.add('$text');
      return;
    }

    final String id = _idOf(item);
    if (id.isEmpty) return;
    texts.add(_optionLabel(question, id) ?? id);
  }

  if (value is List) {
    value.forEach(add);
  } else if (value is Map) {
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.value is Map) {
        final Map<Object?, Object?> map = Map<Object?, Object?>.from(
          entry.value as Map,
        );
        map['id'] ??= entry.key;
        add(map);
      } else {
        add(entry.value);
      }
    }
  } else {
    add(value);
  }

  return _unique(texts);
}
