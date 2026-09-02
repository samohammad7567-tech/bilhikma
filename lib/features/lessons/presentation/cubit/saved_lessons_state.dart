part of 'saved_lessons_cubit.dart';

enum SavedLessonsStatus { initial, loading, success, failure }

final class SavedLessonsState {
  const SavedLessonsState({
    this.status = SavedLessonsStatus.initial,
    this.selectedMediaType = ContentType.audio,
    this.allSaved,
    this.errorKey,
  });

  final SavedLessonsStatus status;
  final ContentType selectedMediaType;

  final List<LessonModel>? allSaved;
  final String? errorKey;

  bool get isLoading => status == SavedLessonsStatus.loading;

  bool get isFirstLoad => isLoading && allSaved == null;

  SavedLessonsState copyWith({
    SavedLessonsStatus? status,
    ContentType? selectedMediaType,
    List<LessonModel>? allSaved,
    String? errorKey,
    bool clearError = false,
  }) => SavedLessonsState(
    status: status ?? this.status,
    selectedMediaType: selectedMediaType ?? this.selectedMediaType,
    allSaved: allSaved ?? this.allSaved,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
