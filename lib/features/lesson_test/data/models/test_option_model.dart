import '../../../../core/network/json_reader.dart';

class TestOptionModel {
  const TestOptionModel({
    required this.id,
    required this.label,
    this.imageUrl,
    this.isReusable = false,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final bool isReusable;

  factory TestOptionModel.fromJson(Map<String, dynamic> json) =>
      TestOptionModel(
        id: Json.asString(json['id']),
        label: Json.asString(json['text'] ?? json['label']),
        imageUrl: Json.asOptionalString(json['image_path'] ?? json['image']),
        isReusable: Json.asBool(json['is_reusable']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': label,
    'image_path': imageUrl,
    'is_reusable': isReusable,
  };
}
