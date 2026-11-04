import '../../../../core/network/json_reader.dart';

class QuizSaveResultModel {
  const QuizSaveResultModel({
    required this.attemptId,
    required this.saved,
    required this.serverNow,
    this.ignoredQuestionIds = const <String>[],
    this.expiresAt,
    this.secondsLeft,
    this.hasExpired = false,
  });

  final int attemptId;
  final int saved;
  final List<String> ignoredQuestionIds;
  final DateTime serverNow;
  final DateTime? expiresAt;
  final int? secondsLeft;
  final bool hasExpired;

  factory QuizSaveResultModel.fromJson(Map<String, dynamic> json) =>
      QuizSaveResultModel(
        attemptId: Json.asInt(json['attempt_id']),
        saved: Json.asInt(json['saved']),
        ignoredQuestionIds: Json.asStringList(json['ignored_question_ids']),
        serverNow: Json.asDateTime(json['server_now']) ?? DateTime.now(),
        expiresAt: Json.asDateTime(json['expires_at']),
        secondsLeft: Json.asOptionalInt(json['seconds_left']),
        hasExpired: Json.asBool(json['has_expired']),
      );
}
