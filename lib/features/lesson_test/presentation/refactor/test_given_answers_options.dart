part of 'test_given_answers.dart';

List<QuizReviewAnswer> _textItems(Iterable<String> values) => values
    .map((String text) => QuizReviewAnswer(text: text.trim()))
    .where((QuizReviewAnswer answer) => !answer.isEmpty)
    .toList(growable: false);

List<QuizReviewAnswer> _optionItems(
  Object? value,
  TestQuestionModel? question,
  QuizQuestionResultModel result,
) {
  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];

  void add(Object? raw) {
    if (raw == null) return;

    final String id = _idOf(raw);
    String? text;
    String? image;
    String? feedback;

    if (raw is Map) {
      text = _stringOf(
        raw['text'] ?? raw['label'] ?? raw['option_text'] ?? raw['answer'],
      );
      image = MediaUrl.resolve(
        _stringOf(raw['image_path'] ?? raw['image'] ?? raw['option_image_path']),
      );
      feedback = _stringOf(
        raw['feedback'] ?? raw['option_feedback'] ?? raw['comment'],
      );
    }

    final TestOptionModel? option = question?.optionById(id);
    final TestOptionModel? solution = result.solutionOptionFor(id);
    text ??= option?.label ?? solution?.label;
    image ??= option?.imageUrl ?? solution?.imageUrl;
    feedback ??= solution?.feedback ?? option?.feedback;

    final String resolvedText = (text ?? id).trim();
    final String? resolvedFeedback = _stringOf(feedback);

    if (resolvedText.isEmpty && (image == null || image.trim().isEmpty)) {
      return;
    }

    items.add(
      QuizReviewAnswer(
        text: resolvedText,
        imageUrl: image,
        feedback: resolvedFeedback,
      ),
    );
  }

  if (value is List) {
    value.forEach(add);
  } else if (value is Map) {
    value.values.forEach(add);
  } else {
    add(value);
  }

  return items;
}

List<String> _options(Object? value, TestQuestionModel? question) {
  final List<String> ids = <String>[];

  if (value is List) {
    for (final Object? item in value) {
      final String id = _idOf(item);
      if (id.isNotEmpty) ids.add(id);
    }
  } else {
    final String id = _idOf(value);
    if (id.isNotEmpty) ids.add(id);
  }

  return ids
      .map((String id) => question?.optionById(id)?.label ?? id)
      .where((String text) => text.trim().isNotEmpty)
      .toList(growable: false);
}

List<String> _trueFalse(Object? value) {
  if (value is bool) {
    return <String>[value ? LangKeys.quizTrue.tr() : LangKeys.quizFalse.tr()];
  }

  final String text = '$value'.trim().toLowerCase();
  if (text == 'true' || text == '1') {
    return <String>[LangKeys.quizTrue.tr()];
  }
  if (text == 'false' || text == '0') {
    return <String>[LangKeys.quizFalse.tr()];
  }

  return const <String>[];
}

String? _stringOf(Object? value) {
  if (value == null) return null;
  if (value is Map || value is List) return null;

  final String text = '$value'.trim();
  return text.isEmpty ? null : text;
}

Object? _first(Map<String, dynamic> given, List<String> keys) {
  for (final String key in keys) {
    final Object? value = given[key];
    if (value != null) return value;
  }
  return null;
}

String _idOf(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    return _idOf(value['id'] ?? value['text'] ?? value['label']);
  }
  if (value is List) return '';

  return '$value'.trim();
}
