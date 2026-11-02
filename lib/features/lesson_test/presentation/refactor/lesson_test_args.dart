class LessonTestArgs {
  const LessonTestArgs({
    required this.lessonId,
    this.lessonTitle,
    this.categorySubjectId,
    this.lessonOrder,
  });

  final int lessonId;
  final String? lessonTitle;
  final int? categorySubjectId;
  final int? lessonOrder;

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
