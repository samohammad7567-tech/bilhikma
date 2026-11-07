import '../../../../core/network/json_reader.dart';
import 'question_timer_model.dart';
import 'quiz_policy_model.dart';
import 'quiz_question_result_model.dart';
import 'test_question_model.dart';

class QuizAttemptModel {
  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.attemptNo,
    this.score,
    this.maxScore = 0,
    this.scorePercent,
    this.isPassed,
    this.reviewStatus = 'none',
    this.attemptsUsed,
    this.attemptsLeft,
    this.nextAttemptAt,
    this.startedAt,
    this.expiresAt,
    this.submittedAt,
    this.durationSeconds,
    this.serverNow,
    this.questionTimingEnabled = true,
    this.serverHasExpired = false,
    this.serverIsSubmitted = false,
    this.policy = const QuizPolicyModel(),
    this.questions = const <TestQuestionModel>[],
    this.questionResults = const <QuizQuestionResultModel>[],
    this.savedAnswers = const <String, Map<String, dynamic>>{},
  });

  final int id;
  final int quizId;
  final int studentId;
  final int attemptNo;

  final double? score;
  final double maxScore;
  final int? scorePercent;
  final bool? isPassed;
  final String reviewStatus;

  final int? attemptsUsed;
  final int? attemptsLeft;
  final DateTime? nextAttemptAt;

  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? submittedAt;
  final int? durationSeconds;
  final DateTime? serverNow;
  final bool questionTimingEnabled;

  final bool serverHasExpired;
  final bool serverIsSubmitted;

  final QuizPolicyModel policy;
  final List<TestQuestionModel> questions;
  final List<QuizQuestionResultModel> questionResults;
  final Map<String, Map<String, dynamic>> savedAnswers;

  bool get isSubmitted => serverIsSubmitted || submittedAt != null;

  bool get isPendingReview => reviewStatus == 'pending';

  bool get hasSolutions =>
      questionResults.any((QuizQuestionResultModel item) => item.hasSolution);

  bool get hasExpired =>
      serverHasExpired ||
      (expiresAt?.isBefore(serverNow ?? DateTime.now()) ?? false);

  Duration? get remaining => expiresAt?.difference(serverNow ?? DateTime.now());

  Map<String, QuestionTimerModel> get questionTimers =>
      <String, QuestionTimerModel>{
        for (final TestQuestionModel question in questions)
          if (question.initialTimer != null)
            question.id: question.initialTimer!,
      };

  QuizAttemptModel copyWith({
    DateTime? expiresAt,
    DateTime? serverNow,
    bool? questionTimingEnabled,
    bool? serverHasExpired,
  }) => QuizAttemptModel(
    id: id,
    quizId: quizId,
    studentId: studentId,
    attemptNo: attemptNo,
    score: score,
    maxScore: maxScore,
    scorePercent: scorePercent,
    isPassed: isPassed,
    reviewStatus: reviewStatus,
    attemptsUsed: attemptsUsed,
    attemptsLeft: attemptsLeft,
    nextAttemptAt: nextAttemptAt,
    startedAt: startedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    submittedAt: submittedAt,
    durationSeconds: durationSeconds,
    serverNow: serverNow ?? this.serverNow,
    questionTimingEnabled: questionTimingEnabled ?? this.questionTimingEnabled,
    serverHasExpired: serverHasExpired ?? this.serverHasExpired,
    policy: policy,
    questions: questions,
    questionResults: questionResults,
    savedAnswers: savedAnswers,
  );

  Duration? get duration =>
      durationSeconds == null ? null : Duration(seconds: durationSeconds!);

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    final String reviewStatus =
        Json.asOptionalString(json['review_status'])?.toLowerCase() ?? 'none';

    final List<Map<String, dynamic>> answers = Json.asMapList(json['answers']);

    final double? score = json['score'] == null
        ? null
        : Json.asDouble(json['score']);

    final bool? hasPassed = Json.asOptionalBool(json['is_passed']);

    final DateTime? submittedAt = Json.asDateTime(json['submitted_at']);

    final Object? timingEnabled = json['question_timing_enabled'];

    final List<QuizQuestionResultModel> results = answers
        .where(
          (Map<String, dynamic> answer) =>
              answer['is_correct'] != null ||
              answer['awarded_score'] != null ||
              answer['given_answer'] != null,
        )
        .map(QuizQuestionResultModel.fromJson)
        .toList(growable: false);

    return QuizAttemptModel(
      id: Json.asInt(json['id']),
      quizId:
          Json.asOptionalInt(json['assessment_id']) ??
          Json.asInt(json['quiz_id']),
      studentId: Json.asInt(json['student_id']),
      attemptNo: Json.asInt(json['attempt_no']),
      score: score,
      maxScore: Json.asDouble(json['max_score']),
      scorePercent: Json.asOptionalInt(json['score_percent']),
      isPassed: hasPassed,
      reviewStatus: reviewStatus,
      attemptsUsed: Json.asOptionalInt(json['attempts_used']),
      attemptsLeft: Json.asOptionalInt(json['attempts_left']),
      nextAttemptAt: Json.asDateTime(json['next_attempt_at']),
      startedAt: Json.asDateTime(json['started_at']),
      expiresAt: Json.asDateTime(json['expires_at']),
      submittedAt: submittedAt,
      durationSeconds: Json.asOptionalInt(json['duration_seconds']),
      serverNow: Json.asDateTime(json['server_now']),
      questionTimingEnabled: timingEnabled == null
          ? true
          : Json.asBool(timingEnabled),
      serverHasExpired: Json.asBool(json['has_expired']),
      serverIsSubmitted:
          submittedAt != null ||
          score != null ||
          hasPassed != null ||
          reviewStatus != 'none',
      policy: QuizPolicyModel.fromJson(Json.asMap(json['policy_snapshot'])),
      questions: answers
          .map(TestQuestionModel.fromJson)
          .toList(growable: false),
      questionResults: results,
      savedAnswers: _savedAnswers(json['saved_answers']),
    );
  }

  static Map<String, Map<String, dynamic>> _savedAnswers(Object? value) {
    final Map<String, dynamic> raw = Json.asMap(value);
    if (raw.isEmpty) return const <String, Map<String, dynamic>>{};

    return <String, Map<String, dynamic>>{
      for (final MapEntry<String, dynamic> entry in raw.entries)
        if (entry.value is Map)
          entry.key: Map<String, dynamic>.from(entry.value as Map),
    };
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'quiz_id': quizId,
    'assessment_id': quizId,
    'student_id': studentId,
    'attempt_no': attemptNo,
    'score': score,
    'max_score': maxScore,
    'score_percent': scorePercent,
    'is_passed': isPassed,
    'review_status': reviewStatus,
    'attempts_used': attemptsUsed,
    'attempts_left': attemptsLeft,
    'next_attempt_at': nextAttemptAt?.toIso8601String(),
    'started_at': startedAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'submitted_at': submittedAt?.toIso8601String(),
    'duration_seconds': durationSeconds,
    'server_now': serverNow?.toIso8601String(),
    'question_timing_enabled': questionTimingEnabled,
    'has_expired': serverHasExpired,
    'policy_snapshot': policy.toJson(),
    'answers': questions
        .map((TestQuestionModel question) => question.toJson())
        .toList(growable: false),
    'saved_answers': savedAnswers,
  };
}
