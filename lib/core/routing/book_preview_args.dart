class BookPreviewArgs {
  const BookPreviewArgs({
    required this.filePath,
    required this.title,
    this.contentId,
    this.resumeKey,
  });

  final String filePath;
  final String title;

  final int? contentId;
  final String? resumeKey;
  String get readingKey {
    final String? key = resumeKey;
    if (key != null && key.isNotEmpty) return key;

    return 'file:${Uri.file(filePath).pathSegments.last}';
  }
}
