import '../../../../core/network/json_reader.dart';
import 'question_timer_model.dart';

class QuestionStartModel {
  const QuestionStartModel({
    required this.attemptId,
    required this.questionId,
    required this.serverNow,
    required this.timer,
    this.attemptExpiresAt,
    this.savedAnswer,
  });

  final int attemptId;
  final String questionId;
  final DateTime serverNow;
  final DateTime? attemptExpiresAt;
  final QuestionTimerModel timer;
  final Map<String, dynamic>? savedAnswer;

  factory QuestionStartModel.fromJson(Map<String, dynamic> json) =>
      QuestionStartModel(
        attemptId: Json.asInt(json['attempt_id']),
        questionId: Json.asString(json['question_id']),
        serverNow: Json.asDateTime(json['server_now']) ?? DateTime.now(),
        attemptExpiresAt: Json.asDateTime(json['attempt_expires_at']),
        timer: QuestionTimerModel.fromJson(Json.asMap(json['timer'])),
        savedAnswer: Json.asOptionalMap(json['saved_answer']),
      );
}
