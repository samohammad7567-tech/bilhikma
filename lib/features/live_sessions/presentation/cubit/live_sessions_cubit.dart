import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/live_session_model.dart';
import '../../data/repos/live_sessions_repo.dart';

part 'live_sessions_state.dart';

class LiveSessionsCubit extends Cubit<LiveSessionsState> {
  LiveSessionsCubit({this.repo = const LiveSessionsRepo()})
    : super(const LiveSessionsState()) {
    loadSessions();
  }

  final LiveSessionsRepo repo;

  Future<void> loadSessions() async {
    emit(state.copyWith(status: LiveSessionsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final List<LiveSessionModel> sessions = await repo.fetchSessions();
      if (isClosed) return;

      final List<LiveSessionModel> ordered = _ordered(sessions);

      emit(
        state.copyWith(
          status: ordered.isEmpty
              ? LiveSessionsStatus.empty
              : LiveSessionsStatus.success,
          sessions: ordered,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: LiveSessionsStatus.failure, errorKey: error.key),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LiveSessionsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  List<LiveSessionModel> _ordered(List<LiveSessionModel> sessions) {
    final List<LiveSessionModel> ordered = List<LiveSessionModel>.of(sessions)
      ..sort((LiveSessionModel a, LiveSessionModel b) {
        final int bucket = _bucket(a).compareTo(_bucket(b));
        if (bucket != 0) return bucket;

        final DateTime? left = a.scheduledAt;
        final DateTime? right = b.scheduledAt;
        if (left == null || right == null) return 0;

        return left.compareTo(right);
      });

    return ordered;
  }

  int _bucket(LiveSessionModel session) {
    if (session.isLive) return 0;
    if (session.isUpcoming) return 1;
    return 2;
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));
}
