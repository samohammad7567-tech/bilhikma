part of 'test_solution_answers.dart';

List<QuizReviewAnswer> _orderedItems(
  Object? value, {
  TestQuestionModel? question,
}) {
  if (value is! List) return const <QuizReviewAnswer>[];

  final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];
  final Set<String> seen = <String>{};

  for (final Object? item in value) {
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
    final String? resolvedImage = image ?? sentence?.imageUrl;

    if (resolvedText.isEmpty &&
        (resolvedImage == null || resolvedImage.trim().isEmpty)) {
      continue;
    }

    final String key = '$resolvedText|${resolvedImage ?? ''}';
    if (!seen.add(key)) continue;

    items.add(QuizReviewAnswer(text: resolvedText, imageUrl: resolvedImage));
  }

  return items;
}

List<String> _texts(Object? value, {TestQuestionModel? question}) {
  if (value is! List) return const <String>[];

  final List<String> texts = <String>[];

  for (final Object? item in value) {
    if (item is Map) {
      final Object? text = item['text'] ?? item['label'];
      final String resolved = text != null
          ? '$text'
          : _sentenceText(question, _idOf(item)) ?? _idOf(item);
      if (resolved.trim().isNotEmpty) texts.add(resolved);
      continue;
    }

    final String id = _idOf(item);
    final String text = _sentenceText(question, id) ?? id;
    if (text.trim().isNotEmpty) texts.add(text);
  }

  return _unique(texts);
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
