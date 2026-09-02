import '../../../../core/network/json_reader.dart';
import 'test_question_model.dart';

class LessonTestModel {
  const LessonTestModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.duration,
    required this.questions,
    this.passPercent = 70,
    this.retryAfterDays = 3,
  });

  final String id;
  final String lessonId;
  final String title;

  final Duration duration;

  final int passPercent;

  final int retryAfterDays;

  final List<TestQuestionModel> questions;

  int get questionCount => questions.length;

  bool get hasQuestions => questions.isNotEmpty;

  TestQuestionModel? questionAt(int index) =>
      index >= 0 && index < questions.length ? questions[index] : null;

  factory LessonTestModel.fromJson(Map<String, dynamic> json) =>
      LessonTestModel(
        id: Json.asString(json['id']),
        lessonId: Json.asString(json['lesson_id']),
        title: Json.asString(json['title'] ?? json['name']),
        duration:
            Json.asDuration(json['duration'] ?? json['time_limit']) ??
            const Duration(minutes: 10),
        passPercent: _orDefault(
          Json.asInt(json['pass_percent'] ?? json['pass_mark']),
          70,
        ),
        retryAfterDays: _orDefault(Json.asInt(json['retry_after_days']), 3),
        questions: Json.asMapList(
          json['questions'],
        ).map(TestQuestionModel.fromJson).toList(growable: false),
      );

  static int _orDefault(int value, int fallback) =>
      value > 0 ? value : fallback;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'lesson_id': lessonId,
    'title': title,
    'duration': duration.inSeconds,
    'pass_percent': passPercent,
    'retry_after_days': retryAfterDays,
    'questions': questions
        .map((TestQuestionModel question) => question.toJson())
        .toList(growable: false),
  };
}
