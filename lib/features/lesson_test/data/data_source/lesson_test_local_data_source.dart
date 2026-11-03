import 'dart:convert';

import '../../../../core/utils/cache_util.dart';
import '../models/test_answer_model.dart';

class LessonTestSavedAnswersModel {
  const LessonTestSavedAnswersModel({
    required this.attemptId,
    required this.quizId,
    required this.updatedAt,
    required this.answers,
  });

  final int attemptId;
  final int quizId;
  final DateTime updatedAt;
  final Map<String, TestAnswerModel> answers;

  factory LessonTestSavedAnswersModel.fromJson(Map<String, dynamic> json) {
    final Object? rawAnswers = json['answers'];
    final Map<String, TestAnswerModel> answers = <String, TestAnswerModel>{};

    if (rawAnswers is Map) {
      for (final MapEntry<Object?, Object?> entry in rawAnswers.entries) {
        if (entry.value is Map) {
          answers['${entry.key}'] = TestAnswerModel.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }

    return LessonTestSavedAnswersModel(
      attemptId: int.tryParse('${json['attempt_id']}') ?? 0,
      quizId: int.tryParse('${json['quiz_id']}') ?? 0,
      updatedAt: DateTime.tryParse('${json['updated_at']}') ?? DateTime.now(),
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'attempt_id': attemptId,
    'quiz_id': quizId,
    'updated_at': updatedAt.toIso8601String(),
    'answers': <String, dynamic>{
      for (final MapEntry<String, TestAnswerModel> entry in answers.entries)
        entry.key: entry.value.toJson(),
    },
  };
}

class LessonTestLocalDataSource {
  const LessonTestLocalDataSource();

  static String _key(int attemptId) => 'lesson_test_answers_$attemptId';

  LessonTestSavedAnswersModel? read(int attemptId) {
    if (attemptId <= 0) return null;

    final Object? raw = CacheUtil.get(key: _key(attemptId));
    if (raw is! String || raw.isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final LessonTestSavedAnswersModel saved =
          LessonTestSavedAnswersModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );

      return saved.attemptId == attemptId ? saved : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(LessonTestSavedAnswersModel saved) => CacheUtil.setString(
    key: _key(saved.attemptId),
    value: jsonEncode(saved.toJson()),
  );

  void clear(int attemptId) {
    if (attemptId <= 0) return;
    CacheUtil.remove(key: _key(attemptId));
  }
}
