import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/enums/archive_filter_enum.dart';
import '../../data/repos/archive_repo.dart';
import '../../../lessons/data/data_source/saved_lessons_data_source.dart';

part 'archive_state.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
  ArchiveCubit({this.repo = const ArchiveRepo()})
    : super(const ArchiveState()) {
    loadSavedItems();
    SavedLessonsDataSource.revision.addListener(_onSavedItemsChanged);
  }

  @override
  Future<void> close() {
    SavedLessonsDataSource.revision.removeListener(_onSavedItemsChanged);
    return super.close();
  }

  void _onSavedItemsChanged() => unawaited(silentRefresh());

  Future<void> silentRefresh() async {
    emit(state.copyWith(clearCache: true));
    await _load(state.selectedFilter);
    unawaited(_warmOtherFilters());
  }

  final ArchiveRepo repo;

  final Set<ArchiveFilter> _inFlight = <ArchiveFilter>{};

  Future<void> loadSavedItems() async {
    emit(state.copyWith(status: ArchiveStatus.loading));
    await _load(state.selectedFilter);
    unawaited(_warmOtherFilters());
  }

  Future<void> refresh() async {
    emit(state.copyWith(clearCache: true));
    await _load(state.selectedFilter);
    unawaited(_warmOtherFilters());
  }

  void selectFilter(ArchiveFilter filter) {
    if (filter == state.selectedFilter) return;

    final List<LessonModel>? cached = state.cache[filter];
    if (cached != null) {
      emit(
        state.copyWith(
          selectedFilter: filter,
          items: cached,
          status: cached.isEmpty ? ArchiveStatus.empty : ArchiveStatus.success,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(selectedFilter: filter, status: ArchiveStatus.loading));
    unawaited(_load(filter));
  }

  Future<void> _warmOtherFilters() async {
    for (final ArchiveFilter filter in ArchiveFilter.values) {
      if (isClosed) return;
      if (state.cache.containsKey(filter)) continue;

      await _load(filter);
    }
  }

  Future<void> _load(ArchiveFilter filter) async {
    if (!_inFlight.add(filter)) return;

    try {
      final List<LessonModel> items = await repo.fetchSavedItems(
        type: filter.mediaType,
      );
      if (isClosed) return;

      _store(filter, items);
    } on AppException catch (error) {
      if (isClosed) return;
      _fail(filter, error.key);
    } catch (error) {
      if (isClosed) return;
      _fail(filter, ErrorMapper.map(error));
    } finally {
      _inFlight.remove(filter);
    }
  }

  void _store(ArchiveFilter filter, List<LessonModel> items) {
    final Map<ArchiveFilter, List<LessonModel>> cache =
        <ArchiveFilter, List<LessonModel>>{...state.cache, filter: items};

    if (filter != state.selectedFilter) {
      emit(state.copyWith(cache: cache));
      return;
    }

    emit(
      state.copyWith(
        cache: cache,
        status: items.isEmpty ? ArchiveStatus.empty : ArchiveStatus.success,
        items: items,
        clearError: true,
      ),
    );
  }

  void _fail(ArchiveFilter filter, String errorKey) {
    if (filter != state.selectedFilter) return;

    emit(state.copyWith(status: ArchiveStatus.failure, errorKey: errorKey));
  }
}
