/// What the reader should open: a file already on this device, or a signed
/// network URL the viewer streams itself.
class BookPreviewArgs {
  const BookPreviewArgs({
    required this.title,
    this.filePath,
    this.url,
    this.contentId,
    this.resumeKey,
  }) : assert(
         filePath != null || url != null,
         'A preview needs either a filePath or a url',
       );

  const BookPreviewArgs.network({
    required String this.url,
    required this.title,
    this.contentId,
    this.resumeKey,
  }) : filePath = null;

  final String? filePath;

  /// Set when the document is read straight from the backend instead of disk.
  final String? url;

  final String title;

  final int? contentId;
  final String? resumeKey;

  bool get isNetwork => (url ?? '').trim().isNotEmpty;

  String get networkUrl => url!.trim();

  String get localPath => filePath!;

  String get readingKey {
    final String? key = resumeKey;
    if (key != null && key.isNotEmpty) return key;

    if (isNetwork) return 'url:${_lastSegment(Uri.tryParse(networkUrl))}';

    return 'file:${Uri.file(localPath).pathSegments.last}';
  }

  static String _lastSegment(Uri? uri) {
    final List<String> segments = uri?.pathSegments ?? const <String>[];

    return segments.isEmpty ? '' : segments.last;
  }
}
