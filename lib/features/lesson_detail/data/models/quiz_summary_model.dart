import '../../../../core/network/json_reader.dart';

class QuizSummaryModel {
  const QuizSummaryModel({
    required this.id,
    this.isBlocking = false,
    this.hasPassed = false,
  });

  final int id;
  final bool isBlocking;
  final bool hasPassed;

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) =>
      QuizSummaryModel(
        id: Json.asInt(json['id']),
        isBlocking: Json.asBool(json['is_blocking']),
        hasPassed: Json.asBool(json['has_passed']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'is_blocking': isBlocking,
    'has_passed': hasPassed,
  };
}
