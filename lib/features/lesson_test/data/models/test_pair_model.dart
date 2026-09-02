import '../../../../core/network/json_reader.dart';

class TestPairModel {
  const TestPairModel({
    required this.id,
    required this.prompt,
    required this.match,
  });

  final String id;

  final String prompt;

  final String match;

  factory TestPairModel.fromJson(Map<String, dynamic> json) => TestPairModel(
    id: Json.asString(json['id']),
    prompt: Json.asString(json['prompt'] ?? json['sentence']),
    match: Json.asString(json['match'] ?? json['equivalent']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'prompt': prompt,
    'match': match,
  };
}
