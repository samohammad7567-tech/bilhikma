import '../../../../core/network/json_reader.dart';

class TestMatchItemModel {
  const TestMatchItemModel({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  final String id;
  final String text;
  final String? imageUrl;

  factory TestMatchItemModel.fromJson(Map<String, dynamic> json) =>
      TestMatchItemModel(
        id: Json.asString(json['id']),
        text: Json.asString(json['text'] ?? json['label']),
        imageUrl: Json.asOptionalString(json['image_path'] ?? json['image']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'image_path': imageUrl,
  };
}
