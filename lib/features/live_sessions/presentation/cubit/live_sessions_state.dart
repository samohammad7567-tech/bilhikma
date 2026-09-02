part of 'live_sessions_cubit.dart';

enum LiveSessionsStatus { initial, loading, success, failure, empty }

final class LiveSessionsState {
  const LiveSessionsState({
    this.status = LiveSessionsStatus.initial,
    this.sessions,
    this.errorKey,
    this.messageKey,
  });

  final LiveSessionsStatus status;

  final List<LiveSessionModel>? sessions;
  final String? errorKey;
  final String? messageKey;

  bool get isLoading => status == LiveSessionsStatus.loading;
  bool get isFirstLoad => isLoading && sessions == null;

  bool get hasFailed =>
      status == LiveSessionsStatus.failure && sessions == null;

  bool get isEmpty => visibleSessions.isEmpty;

  List<LiveSessionModel> get visibleSessions =>
      sessions ?? const <LiveSessionModel>[];

  LiveSessionsState copyWith({
    LiveSessionsStatus? status,
    List<LiveSessionModel>? sessions,
    String? errorKey,
    String? messageKey,
    bool clearError = false,
  }) => LiveSessionsState(
    status: status ?? this.status,
    sessions: sessions ?? this.sessions,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    messageKey: messageKey,
  );
}
