import '../network/json_reader.dart';

enum AssessmentType {
  lessonQuiz('lesson_quiz'),
  midterm('midterm'),
  finalExam('final_exam'),
  unknown('');

  const AssessmentType(this.key);

  final String key;

  bool get isLessonQuiz => this == AssessmentType.lessonQuiz;

  static AssessmentType fromJson(Object? value) {
    final String? raw = Json.asOptionalString(value)?.toLowerCase();
    if (raw == null) return AssessmentType.lessonQuiz;

    return AssessmentType.values.firstWhere(
      (AssessmentType type) => type.key == raw,
      orElse: () => AssessmentType.unknown,
    );
  }
}
