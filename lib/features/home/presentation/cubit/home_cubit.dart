import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/active_context_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../../data/models/home_overview_model.dart';
import '../../data/models/resume_lesson_model.dart';
import '../../../../core/models/subject_model.dart';
import '../../data/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({this.repo = const HomeRepo()}) : super(const HomeState()) {
    loadOverview();
  }

  final HomeRepo repo;

  Future<void> loadOverview() async {
    emit(state.copyWith(status: HomeStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> _loadEducationalPath() async {
    final List<String> path = await repo.fetchEducationalPath();
    if (isClosed || path.isEmpty) return;

    emit(state.copyWith(educationalPath: path));
  }

  Future<void> _load() async {
    try {
      final HomeOverviewModel overview = await repo.fetchOverview();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          overview: overview,
          clearError: true,
        ),
      );
      unawaited(_loadEducationalPath());

      final LiveSessionModel? session = await repo.fetchHighlightedSession();
      if (isClosed) return;
      emit(
        state.copyWith(liveSession: session, clearLiveSession: session == null),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: HomeStatus.failure, errorKey: error.key));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
