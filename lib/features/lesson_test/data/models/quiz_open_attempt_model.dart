import '../../../../core/network/json_reader.dart';

class QuizOpenAttemptModel {
  const QuizOpenAttemptModel({
    required this.id,
    this.attemptNo = 0,
    this.startedAt,
    this.expiresAt,
    this.answeredCount = 0,
    this.totalQuestions = 0,
    this.remainingSeconds,
  });

  final int id;
  final int attemptNo;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int answeredCount;
  final int totalQuestions;
  final int? remainingSeconds;

  bool get hasExpired => expiresAt?.isBefore(DateTime.now()) ?? false;

  factory QuizOpenAttemptModel.fromJson(Map<String, dynamic> json) =>
      QuizOpenAttemptModel(
        id: Json.asInt(json['id'] ?? json['attempt_id']),
        attemptNo: Json.asOptionalInt(json['attempt_no']) ?? 0,
        startedAt: Json.asDateTime(json['started_at']),
        expiresAt: Json.asDateTime(json['expires_at']),
        answeredCount:
            Json.asOptionalInt(
              json['answered_count'] ?? json['answered_questions'],
            ) ??
            0,
        totalQuestions:
            Json.asOptionalInt(
              json['total_questions'] ?? json['question_count'],
            ) ??
            0,
        remainingSeconds: Json.asOptionalInt(json['remaining_seconds']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'attempt_no': attemptNo,
    'started_at': startedAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'answered_count': answeredCount,
    'total_questions': totalQuestions,
    'remaining_seconds': remainingSeconds,
  };
}
