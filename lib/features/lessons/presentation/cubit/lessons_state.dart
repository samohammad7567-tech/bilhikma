part of 'lessons_cubit.dart';

enum LessonsStatus { initial, loading, success, failure }

final class LessonsState {
  const LessonsState({
    this.status = LessonsStatus.initial,
    this.selectedType = ContentType.video,
    this.subject,
    this.lessons = const <LessonModel>[],
    this.meta = const PaginationMeta(),
    this.isLoadingMore = false,
    this.errorKey,
  });

  final LessonsStatus status;

  final ContentType selectedType;

  final SubjectContentModel? subject;

  final List<LessonModel> lessons;
  final PaginationMeta meta;
  final bool isLoadingMore;
  final String? errorKey;

  bool get isLoading => status == LessonsStatus.loading;
  bool get isFirstLoad => isLoading && subject == null;

  bool get hasFailed => status == LessonsStatus.failure && subject == null;

  bool get hasMore => meta.hasMore;

  String get title => subject?.name ?? '';

  LessonsState copyWith({
    LessonsStatus? status,
    ContentType? selectedType,
    SubjectContentModel? subject,
    List<LessonModel>? lessons,
    PaginationMeta? meta,
    bool? isLoadingMore,
    String? errorKey,
    bool clearError = false,
  }) => LessonsState(
    status: status ?? this.status,
    selectedType: selectedType ?? this.selectedType,
    subject: subject ?? this.subject,
    lessons: lessons ?? this.lessons,
    meta: meta ?? this.meta,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
