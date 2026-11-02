import '../../../../core/network/json_reader.dart';

class TestSentenceModel {
  const TestSentenceModel({
    required this.id,
    required this.text,
    this.position = 0,
  });

  final String id;
  final String text;

  final int position;

  factory TestSentenceModel.fromJson(Map<String, dynamic> json) =>
      TestSentenceModel(
        id: Json.asString(json['id']),
        text: Json.asString(json['text'] ?? json['sentence']),
        position: Json.asOptionalInt(json['position'] ?? json['order']) ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'position': position,
  };
}
