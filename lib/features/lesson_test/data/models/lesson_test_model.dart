import '../../../../core/network/json_reader.dart';
import 'test_question_model.dart';

class LessonTestModel {
  const LessonTestModel({
    required this.id,
    required this.title,
    this.lessonId,
    this.contentId,
    this.instructions,
    this.duration = Duration.zero,
    this.passPercent = 50,
    this.retryAfterDays = 0,
    this.questions = const <TestQuestionModel>[],
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
  });

  final int id;
  final String title;

  @Deprecated('Legacy mock only; use contentId.')
  final String? lessonId;

  final int? contentId;
  final String? instructions;

  @Deprecated('Legacy mock only; use timeLimitMinutes.')
  final Duration duration;

  @Deprecated('Legacy mock only; use passScore.')
  final int passPercent;

  @Deprecated('Legacy mock only; use retryCooldownMin.')
  final int retryAfterDays;

  @Deprecated('Legacy mock only; questions arrive from the attempt.')
  final List<TestQuestionModel> questions;

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

  bool get hasQuestions => questions.isNotEmpty;

  bool get hasTimeLimit => timeLimitMinutes != null && timeLimitMinutes! > 0;

  bool get hasUnlimitedAttempts => attemptsLeft == null;

  bool get hasAttemptsLeft => attemptsLeft == null || attemptsLeft! > 0;

  bool get isInCooldown => nextAttemptAt?.isAfter(DateTime.now()) ?? false;

  TestQuestionModel? questionAt(int index) =>
      index >= 0 && index < questions.length ? questions[index] : null;

  factory LessonTestModel.fromJson(Map<String, dynamic> json) {
    final bool overviewShape =
        json.containsKey('content_id') ||
        json.containsKey('question_count') ||
        json.containsKey('attempts_used');

    if (overviewShape) return LessonTestModel._fromOverview(json);

    return LessonTestModel._fromLegacy(json);
  }

  factory LessonTestModel._fromOverview(Map<String, dynamic> json) {
    final int? timeLimit = Json.asOptionalInt(json['time_limit_minutes']);

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
      duration: timeLimit == null
          ? Duration.zero
          : Duration(minutes: timeLimit),
      passPercent: Json.asOptionalInt(json['pass_score']) ?? 50,
      retryAfterDays: Json.asOptionalInt(json['retry_cooldown_minutes']) ?? 0,
    );
  }

  factory LessonTestModel._fromLegacy(Map<String, dynamic> json) {
    final List<TestQuestionModel> questions = Json.asMapList(
      json['questions'],
    ).map(TestQuestionModel.fromJson).toList(growable: false);

    return LessonTestModel(
      id: Json.asString(json['id']).isEmpty ? 0 : Json.asInt(json['id']),
      title: Json.asString(json['title'] ?? json['name']),
      lessonId: Json.asOptionalString(json['lesson_id']),
      duration:
          Json.asDuration(json['duration'] ?? json['time_limit']) ??
          const Duration(minutes: 10),
      passPercent: _orDefault(
        Json.asInt(json['pass_percent'] ?? json['pass_mark']),
        50,
      ),
      retryAfterDays: Json.asInt(json['retry_after_days']),
      questions: questions,
      questionCount: questions.length,
      passScore: _orDefault(
        Json.asInt(json['pass_percent'] ?? json['pass_mark']),
        50,
      ),
      retryCooldownMin: Json.asInt(json['retry_after_days']),
      timeLimitMinutes: Json.asDuration(
        json['duration'] ?? json['time_limit'],
      )?.inMinutes,
    );
  }

  static int _orDefault(int value, int fallback) =>
      value > 0 ? value : fallback;

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
  };
}
