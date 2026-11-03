import '../../../../core/network/json_reader.dart';

class QuizSummaryModel {
  const QuizSummaryModel({
    required this.id,
    this.isBlocking = false,
    this.hasPassed = false,
    this.latestAttemptId,
  });

  final int id;
  final bool isBlocking;
  final bool hasPassed;
  final int? latestAttemptId;

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) =>
      QuizSummaryModel(
        id: Json.asInt(json['id']),
        isBlocking: Json.asBool(json['is_blocking']),
        hasPassed: Json.asBool(json['has_passed']),
        latestAttemptId: Json.asOptionalInt(json['latest_attempt_id']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'is_blocking': isBlocking,
    'has_passed': hasPassed,
    'latest_attempt_id': latestAttemptId,
  };
}
