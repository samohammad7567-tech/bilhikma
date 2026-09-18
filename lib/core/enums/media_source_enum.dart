import '../network/json_reader.dart';

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
      orElse: () => MediaSource.file,
    );
  }
}
