import '../../enums/video_source_kind_enum.dart';

class VideoItem {
  const VideoItem({
    required this.id,
    required this.kind,
    required this.source,
    this.isLive = false,
    this.title,
    this.subtitle,
    this.description,
    this.date,
    this.shareText,
    this.httpHeaders = const <String, String>{},
  });

  factory VideoItem.youtube({
    required String id,
    required String youtubeVideoId,
    bool isLive = false,
    String? title,
    String? subtitle,
    String? description,
    String? date,
    String? shareText,
  }) => VideoItem(
    id: id,
    kind: VideoSourceKind.youtube,
    source: youtubeVideoId,
    isLive: isLive,
    title: title,
    subtitle: subtitle,
    description: description,
    date: date,
    shareText: shareText,
  );

  factory VideoItem.network({
    required String id,
    required String url,
    bool? isLive,
    String? title,
    String? subtitle,
    String? description,
    String? date,
    String? shareText,
    Map<String, String> httpHeaders = const <String, String>{},
  }) => VideoItem(
    id: id,
    kind: VideoSourceKind.network,
    source: url,
    isLive: isLive ?? looksLive(url),
    title: title,
    subtitle: subtitle,
    description: description,
    date: date,
    shareText: shareText,
    httpHeaders: httpHeaders,
  );

  static VideoItem? fromUrl(
    String url, {
    required String id,
    bool? isLive,
    String? title,
    String? subtitle,
    String? description,
    String? date,
    String? shareText,
    Map<String, String> httpHeaders = const <String, String>{},
  }) {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (isYoutubeUrl(trimmed)) {
      final String? videoId = extractYoutubeId(trimmed);
      if (videoId == null || videoId.isEmpty) return null;

      return VideoItem.youtube(
        id: id,
        youtubeVideoId: videoId,
        isLive: isLive ?? trimmed.contains('/live/'),
        title: title,
        subtitle: subtitle,
        description: description,
        date: date,
        shareText: shareText,
      );
    }

    return VideoItem.network(
      id: id,
      url: trimmed,
      isLive: isLive,
      title: title,
      subtitle: subtitle,
      description: description,
      date: date,
      shareText: shareText,
      httpHeaders: httpHeaders,
    );
  }

  final String id;

  final VideoSourceKind kind;

  final String source;

  final bool isLive;

  final String? title;
  final String? subtitle;
  final String? description;
  final String? date;

  final String? shareText;

  final Map<String, String> httpHeaders;

  String? get youtubeVideoId => kind == VideoSourceKind.youtube ? source : null;

  Uri? get mediaUri =>
      kind == VideoSourceKind.network ? Uri.tryParse(source) : null;

  static bool isYoutubeUrl(String url) {
    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return false;

    final String host = uri.host.toLowerCase();

    return host.contains('youtube.com') ||
        host.contains('youtube-nocookie.com') ||
        host.contains('youtu.be');
  }

  static String? extractYoutubeId(String url) {
    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    if (uri.host.toLowerCase().contains('youtu.be')) {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }

    final List<String> segments = uri.pathSegments;

    for (final String marker in const <String>[
      'live',
      'shorts',
      'embed',
      'v',
    ]) {
      final int index = segments.indexOf(marker);
      if (index != -1 && index + 1 < segments.length) {
        return segments[index + 1];
      }
    }

    return uri.queryParameters['v'];
  }

  static bool looksLive(String url) {
    final String lower = url.toLowerCase();

    return lower.contains('.m3u8') ||
        lower.contains('/live/') ||
        lower.contains('livestream');
  }
}
