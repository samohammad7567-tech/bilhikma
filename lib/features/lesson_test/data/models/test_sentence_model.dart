import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/media_url.dart';

class TestSentenceModel {
  const TestSentenceModel({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });

  final String id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;

  factory TestSentenceModel.fromJson(Map<String, dynamic> json) =>
      TestSentenceModel(
        id: Json.asString(json['id']),
        text:
            Json.asOptionalString(json['text']) ??
            Json.asOptionalString(json['label']) ??
            Json.asOptionalString(json['sentence']) ??
            '',
        imageUrl: MediaUrl.resolve(
          Json.asOptionalString(json['image_path'] ?? json['image']),
        ),
        audioUrl: MediaUrl.resolve(
          Json.asOptionalString(json['audio_path'] ?? json['audio']),
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'image_path': imageUrl,
    'audio_path': audioUrl,
  };
}
