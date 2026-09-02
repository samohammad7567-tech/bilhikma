class LessonTestArgs {
  const LessonTestArgs({required this.lessonId, this.lessonTitle});

  final String lessonId;
  final String? lessonTitle;

  factory LessonTestArgs.fromRoute(Object? arguments) =>
      arguments is LessonTestArgs
      ? arguments
      : LessonTestArgs(lessonId: arguments is String ? arguments : '');
}
