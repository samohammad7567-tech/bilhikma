import '../../../../core/enums/content_type_enum.dart';

class LessonTestArgs {
  const LessonTestArgs({
    required this.lessonId,
    this.quizId,
    this.attemptId,
    this.openResult = false,
    this.contentType = ContentType.video,
    this.openLessonOnBack = false,
    this.categorySubjectId = 0,
  });

  final int lessonId;
  final int? quizId;
  final int? attemptId;
  final bool openResult;
  final ContentType contentType;
  final bool openLessonOnBack;
  final int categorySubjectId;

  factory LessonTestArgs.fromRoute(Object? arguments) {
    if (arguments is LessonTestArgs) return arguments;

    return LessonTestArgs(
      lessonId: switch (arguments) {
        final int id => id,
        final String id => int.tryParse(id) ?? 0,
        _ => 0,
      },
    );
  }
}
