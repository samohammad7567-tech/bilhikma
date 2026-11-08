class QuizReviewAnswer {
  const QuizReviewAnswer({
    this.text = '',
    this.imageUrl,
    this.secondaryImageUrl,
    this.feedback,
  });

  factory QuizReviewAnswer.pair({
    required String text,
    Iterable<String?> images = const <String?>[],
    String? feedback,
  }) {
    final List<String> urls = _imageList(images);

    return QuizReviewAnswer(
      text: text,
      imageUrl: urls.isEmpty ? null : urls.first,
      secondaryImageUrl: urls.length > 1 ? urls[1] : null,
      feedback: feedback,
    );
  }

  final String text;
  final String? imageUrl;
  final String? secondaryImageUrl;
  final String? feedback;

  List<String> get imageUrls => _imageList(<String?>[imageUrl, secondaryImageUrl]);

  bool get isEmpty => text.trim().isEmpty && imageUrls.isEmpty;

  String get normalizedFeedback {
    final String value = feedback?.trim() ?? '';
    return value;
  }

  static List<String> _imageList(Iterable<String?> values) {
    final List<String> images = <String>[];

    for (final String? value in values) {
      final String image = value?.trim() ?? '';
      if (image.isEmpty) continue;
      images.add(image);
    }

    return images;
  }
}
