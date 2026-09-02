part of 'lesson_save_cubit.dart';

final class LessonSaveState {
  const LessonSaveState({required this.savedIds});

  final Set<int> savedIds;

  bool isSaved(int lessonId) => savedIds.contains(lessonId);
}
