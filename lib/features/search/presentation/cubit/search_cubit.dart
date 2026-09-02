import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/lesson_model.dart';
import '../../data/repos/search_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({this.repo = const SearchRepo()}) : super(const SearchState());

  final SearchRepo repo;

  String? _lastQuery;

  int _requestId = 0;

  void queryChanged(String query) {
    if (query == state.query) return;

    emit(state.copyWith(query: query));
  }

  Future<void> runSearch() async {
    final String query = state.query.trim();

    if (query.isEmpty) return;

    if (query == _lastQuery) return;

    _lastQuery = query;
    final int requestId = ++_requestId;

    emit(state.copyWith(status: SearchStatus.loading));

    try {
      final List<LessonModel> results = await repo.search(query);
      if (requestId != _requestId) return;

      emit(state.copyWith(status: SearchStatus.success, results: results));
    } catch (error) {
      if (requestId != _requestId) return;

      _lastQuery = null;

      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
