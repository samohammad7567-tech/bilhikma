class QuizReviewAnswer {
  const QuizReviewAnswer({this.text = '', this.imageUrl, this.feedback});

  final String text;
  final String? imageUrl;
  final String? feedback;

  bool get isEmpty => text.trim().isEmpty && (imageUrl?.trim().isEmpty ?? true);

  String get normalizedFeedback {
    final String value = feedback?.trim() ?? '';
    return value;
  }
}
