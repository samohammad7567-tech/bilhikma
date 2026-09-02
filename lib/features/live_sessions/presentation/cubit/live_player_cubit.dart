import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/live_attendance_model.dart';
import '../../data/repos/live_sessions_repo.dart';

part 'live_player_state.dart';

class LivePlayerCubit extends Cubit<LivePlayerState> {
  LivePlayerCubit({required this.session, this.repo = const LiveSessionsRepo()})
    : super(const LivePlayerState()) {
    join();
  }

  final LiveSessionModel session;
  final LiveSessionsRepo repo;

  static const Duration _heartbeatInterval = Duration(seconds: 30);

  Timer? _heartbeat;

  Future<void> join() async {
    emit(state.copyWith(status: LivePlayerStatus.joining, clearError: true));

    try {
      final LiveAttendanceModel attendance = await repo.join(session.id);
      if (isClosed) return;

      final String? url = attendance.youtubeUrl ?? session.youtubeUrl;
      final VideoItem? item = url == null
          ? null
          : VideoItem.fromUrl(
              url,
              id: 'live-${session.id}',
              isLive: true,
              title: session.title,
              description: session.description,
            );

      if (item == null) {
        emit(
          state.copyWith(
            status: LivePlayerStatus.failure,
            errorKey: 'live_stream_unavailable',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: LivePlayerStatus.watching,
          attendance: attendance,
          item: item,
          clearError: true,
        ),
      );

      _startHeartbeat();
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: LivePlayerStatus.failure, errorKey: error.key),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LivePlayerStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => _beat());
  }

  Future<void> _beat() async {
    try {
      final LiveAttendanceModel attendance = await repo.heartbeat(session.id);
      if (isClosed) return;
      emit(state.copyWith(attendance: attendance));
    } catch (_) {}
  }

  Future<void> leave() async {
    _heartbeat?.cancel();
    _heartbeat = null;

    try {
      await repo.leave(session.id);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _heartbeat?.cancel();
    return super.close();
  }
}
