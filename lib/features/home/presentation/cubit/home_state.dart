part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.overview,
    this.liveSession,
    this.educationalPath = const <String>[],
    this.errorKey,
  });

  final HomeStatus status;
  final HomeOverviewModel? overview;

  final LiveSessionModel? liveSession;
  final List<String> educationalPath;

  final String? errorKey;

  bool get isLoading => status == HomeStatus.loading;
  bool get isFirstLoad => isLoading && overview == null;

  List<SubjectModel> get subjects =>
      overview?.subjects ?? const <SubjectModel>[];

  ResumeLessonModel? get resume => overview?.resume;

  ActiveContextModel? get context => overview?.context;
  List<String> get classPath {
    if (educationalPath.isNotEmpty) return educationalPath;

    final String className = context?.categoryName.trim() ?? '';

    return className.isEmpty ? const <String>[] : <String>[className];
  }

  double get overallProgress => overview?.summary.progress ?? 0;

  int get lessonsCount => overview?.summary.lessonsCount ?? 0;
  int get subjectsCount => overview?.summary.subjectsCount ?? 0;

  bool get isAwaitingApproval =>
      status == HomeStatus.success && (overview?.isAwaitingApproval ?? false);

  HomeState copyWith({
    HomeStatus? status,
    HomeOverviewModel? overview,
    LiveSessionModel? liveSession,
    List<String>? educationalPath,
    String? errorKey,
    bool clearError = false,
    bool clearLiveSession = false,
  }) => HomeState(
    status: status ?? this.status,
    overview: overview ?? this.overview,
    liveSession: clearLiveSession ? null : liveSession ?? this.liveSession,
    educationalPath: educationalPath ?? this.educationalPath,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
