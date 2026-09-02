import '../../../../core/network/json_reader.dart';

class TestOptionModel {
  const TestOptionModel({
    required this.id,
    required this.label,
    this.isCorrect = false,
    this.isMostCorrect = false,
  });

  final String id;
  final String label;

  final bool isCorrect;
  final bool isMostCorrect;

  factory TestOptionModel.fromJson(Map<String, dynamic> json) =>
      TestOptionModel(
        id: Json.asString(json['id']),
        label: Json.asString(json['label'] ?? json['text']),
        isCorrect: Json.asBool(json['is_correct'] ?? json['correct']),
        isMostCorrect: Json.asBool(
          json['is_most_correct'] ?? json['most_correct'],
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'label': label,
    'is_correct': isCorrect,
    'is_most_correct': isMostCorrect,
  };
}
