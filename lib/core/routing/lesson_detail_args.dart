import '../enums/content_type_enum.dart';
import '../models/lesson_model.dart';

class LessonDetailArgs {
  const LessonDetailArgs({
    required this.id,
    this.type = ContentType.video,
    this.isCompleted = false,
  });

  final int id;
  final ContentType type;
  final bool isCompleted;

  bool get isValid => id > 0;

  factory LessonDetailArgs.fromLesson(LessonModel lesson) => LessonDetailArgs(
    id: lesson.id,
    type: lesson.type,
    isCompleted: lesson.progress.isCompleted,
  );

  factory LessonDetailArgs.fromRoute(Object? arguments) {
    if (arguments is LessonDetailArgs) return arguments;

    return LessonDetailArgs(
      id: switch (arguments) {
        final int id => id,
        final String id => int.tryParse(id) ?? 0,
        _ => 0,
      },
    );
  }
}
