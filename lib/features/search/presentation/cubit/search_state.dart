part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, failure }

final class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results,
    this.errorKey,
  });

  final SearchStatus status;
  final String query;
  final List<LessonModel>? results;
  final String? errorKey;

  bool get isLoading => status == SearchStatus.loading;
  bool get isFirstLoad => isLoading && results == null;

  bool get hasFailed => status == SearchStatus.failure && results == null;

  bool get hasQuery => query.trim().isNotEmpty;

  List<LessonModel> get visibleResults => results ?? const <LessonModel>[];
  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<LessonModel>? results,
    String? errorKey,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results ?? this.results,
    errorKey: errorKey,
  );
}
