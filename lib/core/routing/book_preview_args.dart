/// Everything the PDF reader needs to open one document.
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

  /// Stable identity of the document across downloads, used to remember the
  /// page it was left at.
  ///
  /// The file path cannot serve: saved names carry a download timestamp, and
  /// a preview of a book that is not saved yet lands in the cache under a new
  /// name every time. [contentId] cannot serve either — for a lesson
  /// attachment it is the lesson id, which every attachment on that lesson
  /// shares. Call sites pass the key of the thing being read.
  final String? resumeKey;

  /// Falls back to the file name so an unidentified document still resumes
  /// for as long as that file exists on disk.
  String get readingKey {
    final String? key = resumeKey;
    if (key != null && key.isNotEmpty) return key;

    return 'file:${Uri.file(filePath).pathSegments.last}';
  }
}
