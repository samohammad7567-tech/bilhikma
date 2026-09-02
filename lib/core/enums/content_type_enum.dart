import '../network/json_reader.dart';

enum ContentType {
  video('video'),
  audio('audio'),
  article('article');

  const ContentType(this.key);

  final String key;

  bool get hasTimeline => this != ContentType.article;

  bool get isVideo => this == ContentType.video;
  bool get isAudio => this == ContentType.audio;
  bool get isArticle => this == ContentType.article;

  bool get isPlayable => this != ContentType.article;

  static ContentType fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return ContentType.values.firstWhere(
      (ContentType type) => type.key == key,
      orElse: () => ContentType.video,
    );
  }
}
