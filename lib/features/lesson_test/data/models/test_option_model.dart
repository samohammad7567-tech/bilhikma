import '../../../../core/network/json_reader.dart';

class TestOptionModel {
  const TestOptionModel({
    required this.id,
    required this.label,
    this.imageUrl,
    this.isCorrect = false,
    this.isMostCorrect = false,
    this.feedback,
  });

  final String id;
  final String label;
  final String? imageUrl;

  final bool isCorrect;
  final bool isMostCorrect;
  final String? feedback;

  factory TestOptionModel.fromJson(Map<String, dynamic> json) =>
      TestOptionModel(
        id: Json.asString(json['id']),
        label: Json.asString(json['text'] ?? json['label']),
        imageUrl: Json.asOptionalString(json['image_path'] ?? json['image']),
        isCorrect: Json.asBool(json['is_correct'] ?? json['correct']),
        isMostCorrect: Json.asBool(
          json['is_most_correct'] ?? json['most_correct'],
        ),
        feedback: Json.asOptionalString(json['feedback']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': label,
    'image_path': imageUrl,
    'is_correct': isCorrect,
    'is_most_correct': isMostCorrect,
    'feedback': feedback,
  };
}
