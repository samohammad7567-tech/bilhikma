import '../../../../core/network/json_reader.dart';
import 'quiz_open_attempt_model.dart';

class LessonTestModel {
  const LessonTestModel({
    required this.id,
    required this.title,
    this.contentId,
    this.instructions,
    this.passScore = 50,
    this.maxAttempts,
    this.retryCooldownMin = 0,
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.isBlocking = false,
    this.showCorrectAnswers = false,
    this.isPublished = false,
    this.selectionMode = '',
    this.questionCount = 0,
    this.totalScore = 0,
    this.attemptsUsed = 0,
    this.attemptsLeft,
    this.hasPassed = false,
    this.nextAttemptAt,
    this.hasOpenAttempt = false,
    this.openAttempt,
  });

  final int id;
  final String title;
  final int? contentId;
  final String? instructions;

  final int passScore;
  final int? maxAttempts;
  final int retryCooldownMin;
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool isBlocking;
  final bool showCorrectAnswers;
  final bool isPublished;
  final String selectionMode;
  final int questionCount;
  final double totalScore;
  final int attemptsUsed;
  final int? attemptsLeft;
  final bool hasPassed;
  final DateTime? nextAttemptAt;
  final bool hasOpenAttempt;
  final QuizOpenAttemptModel? openAttempt;

  bool get hasTimeLimit => timeLimitMinutes != null && timeLimitMinutes! > 0;

  bool get hasUnlimitedAttempts => attemptsLeft == null;

  bool get hasAttemptsLeft => attemptsLeft == null || attemptsLeft! > 0;

  bool get isInCooldown => nextAttemptAt?.isAfter(DateTime.now()) ?? false;

  factory LessonTestModel.fromJson(Map<String, dynamic> json) {
    final int? timeLimit = Json.asOptionalInt(json['time_limit_minutes']);
    final QuizOpenAttemptModel? openAttempt = json['open_attempt'] is Map
        ? QuizOpenAttemptModel.fromJson(
            Map<String, dynamic>.from(json['open_attempt'] as Map),
          )
        : null;

    return LessonTestModel(
      id: Json.asInt(json['id']),
      title: Json.asString(json['title']),
      contentId: Json.asOptionalInt(json['content_id']),
      instructions: Json.asOptionalString(json['instructions']),
      passScore: Json.asOptionalInt(json['pass_score']) ?? 50,
      maxAttempts: Json.asOptionalInt(json['max_attempts']),
      retryCooldownMin: Json.asOptionalInt(json['retry_cooldown_minutes']) ?? 0,
      timeLimitMinutes: timeLimit,
      shuffleQuestions: Json.asBool(json['shuffle_questions']),
      isBlocking: Json.asBool(json['is_blocking']),
      showCorrectAnswers: Json.asBool(json['show_correct_answers']),
      isPublished: Json.asBool(json['is_published']),
      selectionMode: Json.asString(json['selection_mode']),
      questionCount: Json.asInt(json['question_count']),
      totalScore: Json.asDouble(json['total_score']),
      attemptsUsed: Json.asInt(json['attempts_used']),
      attemptsLeft: Json.asOptionalInt(json['attempts_left']),
      hasPassed: Json.asBool(json['has_passed']),
      nextAttemptAt: Json.asDateTime(json['next_attempt_at']),
      hasOpenAttempt:
          Json.asBool(json['has_open_attempt']) || openAttempt != null,
      openAttempt: openAttempt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'content_id': contentId,
    'title': title,
    'instructions': instructions,
    'pass_score': passScore,
    'max_attempts': maxAttempts,
    'retry_cooldown_minutes': retryCooldownMin,
    'time_limit_minutes': timeLimitMinutes,
    'shuffle_questions': shuffleQuestions,
    'is_blocking': isBlocking,
    'show_correct_answers': showCorrectAnswers,
    'is_published': isPublished,
    'selection_mode': selectionMode,
    'question_count': questionCount,
    'total_score': totalScore,
    'attempts_used': attemptsUsed,
    'attempts_left': attemptsLeft,
    'has_passed': hasPassed,
    'next_attempt_at': nextAttemptAt?.toIso8601String(),
    'has_open_attempt': hasOpenAttempt,
    'open_attempt': openAttempt?.toJson(),
  };
}
