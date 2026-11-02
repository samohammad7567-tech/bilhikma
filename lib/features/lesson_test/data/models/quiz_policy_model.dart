import '../../../../core/network/json_reader.dart';

class QuizPolicyModel {
  const QuizPolicyModel({
    this.passScore = 50,
    this.isBlocking = false,
    this.maxAttempts,
    this.shuffleQuestions = false,
    this.timeLimitMinutes,
    this.retryCooldownMinutes = 0,
  });

  final int passScore;
  final bool isBlocking;
  final int? maxAttempts;
  final bool shuffleQuestions;
  final int? timeLimitMinutes;
  final int retryCooldownMinutes;

  factory QuizPolicyModel.fromJson(Map<String, dynamic> json) =>
      QuizPolicyModel(
        passScore: Json.asOptionalInt(json['pass_score']) ?? 50,
        isBlocking: Json.asBool(json['is_blocking']),
        maxAttempts: Json.asOptionalInt(json['max_attempts']),
        shuffleQuestions: Json.asBool(json['shuffle_questions']),
        timeLimitMinutes: Json.asOptionalInt(json['time_limit_minutes']),
        retryCooldownMinutes:
            Json.asOptionalInt(json['retry_cooldown_minutes']) ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'pass_score': passScore,
    'is_blocking': isBlocking,
    'max_attempts': maxAttempts,
    'shuffle_questions': shuffleQuestions,
    'time_limit_minutes': timeLimitMinutes,
    'retry_cooldown_minutes': retryCooldownMinutes,
  };
}
