import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/media_url.dart';

class TestOptionModel {
  const TestOptionModel({
    required this.id,
    required this.label,
    this.imageUrl,
    this.audioUrl,
    this.feedback,
    this.isReusable = false,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final String? audioUrl;
  final String? feedback;
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
        feedback: Json.asOptionalString(
          json['feedback'] ?? json['option_feedback'] ?? json['comment'],
        ),
        isReusable: Json.asBool(json['is_reusable']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': label,
    'image_path': imageUrl,
    'audio_path': audioUrl,
    'feedback': feedback,
    'is_reusable': isReusable,
  };
}
