import '../../../../core/network/json_reader.dart';

class TestSentenceModel {
  const TestSentenceModel({required this.id, required this.text});

  final String id;
  final String text;

  factory TestSentenceModel.fromJson(Map<String, dynamic> json) =>
      TestSentenceModel(
        id: Json.asString(json['id']),
        text: Json.asString(json['text'] ?? json['sentence']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'text': text};
}
