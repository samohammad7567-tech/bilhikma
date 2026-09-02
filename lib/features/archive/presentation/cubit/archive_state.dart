part of 'archive_cubit.dart';

enum ArchiveStatus { initial, loading, success, failure, empty }

final class ArchiveState {
  const ArchiveState({
    this.status = ArchiveStatus.initial,
    this.selectedFilter = ArchiveFilter.audios,
    this.items,
    this.errorKey,
    this.cache = const <ArchiveFilter, List<LessonModel>>{},
  });

  final ArchiveStatus status;
  final ArchiveFilter selectedFilter;
  final List<LessonModel>? items;
  final String? errorKey;

  final Map<ArchiveFilter, List<LessonModel>> cache;

  bool get isLoading => status == ArchiveStatus.loading;

  bool get isFirstLoad => isLoading && !cache.containsKey(selectedFilter);

  bool get hasFailed => status == ArchiveStatus.failure && items == null;

  List<LessonModel> get visibleItems => items ?? const <LessonModel>[];
  ArchiveState copyWith({
    ArchiveStatus? status,
    ArchiveFilter? selectedFilter,
    List<LessonModel>? items,
    String? errorKey,
    bool clearError = false,
    Map<ArchiveFilter, List<LessonModel>>? cache,
    bool clearCache = false,
  }) => ArchiveState(
    status: status ?? this.status,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    items: items ?? this.items,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    cache: clearCache
        ? const <ArchiveFilter, List<LessonModel>>{}
        : cache ?? this.cache,
  );
}
