import '../../../../core/network/json_reader.dart';
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
      serverHasExpired || (expiresAt?.isBefore(DateTime.now()) ?? false);

  Duration? get remaining => expiresAt?.difference(DateTime.now());

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
      quizId: Json.asInt(json['quiz_id']),
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
    'has_expired': serverHasExpired,
    'policy_snapshot': policy.toJson(),
    'answers': questions
        .map((TestQuestionModel question) => question.toJson())
        .toList(growable: false),
    'saved_answers': savedAnswers,
  };
}
