part of 'live_player_cubit.dart';

enum LivePlayerStatus { initial, joining, watching, failure }

final class LivePlayerState {
  const LivePlayerState({
    this.status = LivePlayerStatus.initial,
    this.attendance,
    this.item,
    this.errorKey,
  });

  final LivePlayerStatus status;

  final LiveAttendanceModel? attendance;

  final VideoItem? item;

  final String? errorKey;

  bool get isJoining =>
      status == LivePlayerStatus.joining || status == LivePlayerStatus.initial;

  bool get isWatching => status == LivePlayerStatus.watching && item != null;

  bool get hasFailed => status == LivePlayerStatus.failure;

  LivePlayerState copyWith({
    LivePlayerStatus? status,
    LiveAttendanceModel? attendance,
    VideoItem? item,
    String? errorKey,
    bool clearError = false,
  }) => LivePlayerState(
    status: status ?? this.status,
    attendance: attendance ?? this.attendance,
    item: item ?? this.item,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
