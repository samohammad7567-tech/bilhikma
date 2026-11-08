part of 'test_given_answers.dart';

List<QuizReviewAnswer> _orderItems(
  Object? value,
  TestQuestionModel? question,
  QuizQuestionResultModel result,
) {
  final Object? raw =
      value ??
      result.componentResults['order'] ??
      _componentValues(result.componentResults);
  if (raw is! List) return const <QuizReviewAnswer>[];

  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];

  for (final Object? item in raw) {
    final String id = _idOf(item);
    String? text;
    String? image;

    if (item is Map) {
      text = _stringOf(item['text'] ?? item['label']);
      image = MediaUrl.resolve(
        _stringOf(
          item['image_path'] ?? item['image'] ?? item['sentence_image_path'],
        ),
      );
    }

    final TestSentenceModel? sentence = _sentence(question, id);
    final String resolvedText = (text ?? sentence?.text ?? id).trim();
    image ??= sentence?.imageUrl;
    if (resolvedText.isEmpty && (image == null || image.trim().isEmpty)) {
      continue;
    }

    items.add(QuizReviewAnswer(text: resolvedText, imageUrl: image));
  }

  return items;
}

List<String> _order(
  Object? value,
  TestQuestionModel? question,
  QuizQuestionResultModel result,
) {
  final Object? raw =
      value ??
      result.componentResults['order'] ??
      _componentValues(result.componentResults);
  if (raw is! List) return const <String>[];

  final List<String> texts = <String>[];

  for (final Object? item in raw) {
    if (item is Map) {
      final String id = _idOf(item);
      final Object? text = item['text'] ?? item['label'];
      final String resolved = text != null
          ? '$text'
          : _sentenceText(question, id) ?? id;
      if (resolved.trim().isNotEmpty) texts.add(resolved);
      continue;
    }

    final String id = _idOf(item);
    final String text = _sentenceText(question, id) ?? id;
    if (text.trim().isNotEmpty) texts.add(text);
  }

  return texts;
}

TestSentenceModel? _sentence(TestQuestionModel? question, String id) {
  if (question == null || id.isEmpty) return null;

  for (final TestSentenceModel sentence in question.sentences) {
    if (sentence.id == id) return sentence;
  }

  return null;
}

String? _sentenceText(TestQuestionModel? question, String id) {
  if (question == null || id.isEmpty) return null;

  for (final TestSentenceModel sentence in question.sentences) {
    if (sentence.id == id) return sentence.text;
  }

  return null;
}

Object? _componentValues(Map<String, dynamic> components) {
  if (components.isEmpty) return null;

  return components.values.toList(growable: false);
}
