import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/media_url.dart';

class TestOptionModel {
  const TestOptionModel({
    required this.id,
    required this.label,
    this.imageUrl,
    this.audioUrl,
    this.isReusable = false,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final String? audioUrl;
  final bool isReusable;

  factory TestOptionModel.fromJson(Map<String, dynamic> json) =>
      TestOptionModel(
        id: Json.asString(json['id']),
        label:
            Json.asOptionalString(json['text']) ??
            Json.asOptionalString(json['label']) ??
            '',
        imageUrl: MediaUrl.resolve(
          Json.asOptionalString(json['image_path'] ?? json['image']),
        ),
        audioUrl: MediaUrl.resolve(
          Json.asOptionalString(json['audio_path'] ?? json['audio']),
        ),
        isReusable: Json.asBool(json['is_reusable']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': label,
    'image_path': imageUrl,
    'audio_path': audioUrl,
    'is_reusable': isReusable,
  };
}
