import '../network/json_reader.dart';

/// Where the media behind an access token actually lives. `POST
/// /user/content/{id}/access-token` answers with `file` for an uploaded file
/// served through `/media/{token}`, or `youtube` with a `youtube_url` to play.
enum MediaSource {
  file('file'),
  youtube('youtube');

  const MediaSource(this.key);

  final String key;

  bool get isFile => this == MediaSource.file;
  bool get isYoutube => this == MediaSource.youtube;

  static MediaSource fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return MediaSource.values.firstWhere(
      (MediaSource source) => source.key == key,
      // Endpoints that predate the field send neither, and they all serve
      // uploaded files.
      orElse: () => MediaSource.file,
    );
  }
}
