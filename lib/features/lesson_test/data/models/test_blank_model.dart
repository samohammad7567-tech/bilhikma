import '../../../../core/network/json_reader.dart';

class TestBlankModel {
  const TestBlankModel({
    required this.id,
    this.correctOptionId,
    this.acceptedAnswers = const <String>[],
  });

  final String id;

  final String? correctOptionId;

  final List<String> acceptedAnswers;

  factory TestBlankModel.fromJson(Map<String, dynamic> json) => TestBlankModel(
    id: Json.asString(json['id']),
    correctOptionId: Json.asOptionalString(
      json['correct_option_id'] ?? json['option_id'],
    ),
    acceptedAnswers: Json.asStringList(
      json['accepted_answers'] ?? json['answers'],
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'correct_option_id': correctOptionId,
    'accepted_answers': acceptedAnswers,
  };
}
