part of 'lesson_detail_cubit.dart';

enum LessonDetailStatus { initial, loading, success, failure }

final class LessonDetailState {
  const LessonDetailState({
    this.status = LessonDetailStatus.initial,
    this.detail,
    this.progress = const LessonProgressModel(),
    this.isLocked = false,
    this.playbackUrl,
    this.playbackSource,
    this.isPreparingPlayback = false,
    this.isPlaying = false,
    this.isVideoFullscreen = false,
    this.positionSeconds = 0,
    this.checkpointIndex = 0,
    this.watchedDeltaSeconds = 0,
    this.correctionSeconds,
    this.correctionRevision = 0,
    this.downloadingAttachmentId,
    this.previewingAttachmentId,
    this.downloadedAttachmentIds = const <int>{},
    this.errorKey,
    this.errorMessage,
    this.messageKey,
    this.message,
  });

  final LessonDetailStatus status;
  final LessonDetailModel? detail;

  final LessonProgressModel progress;

  final bool isLocked;

  final String? playbackUrl;
  final MediaSource? playbackSource;

  final bool isPreparingPlayback;
  final bool isPlaying;

  final bool isVideoFullscreen;

  final int positionSeconds;

  final int checkpointIndex;

  final int watchedDeltaSeconds;

  final int? correctionSeconds;
  final int correctionRevision;

  final int? downloadingAttachmentId;
  final int? previewingAttachmentId;

  final Set<int> downloadedAttachmentIds;

  final String? errorKey;

  final String? errorMessage;

  final String? messageKey;

  final String? message;

  bool get isLoading =>
      status == LessonDetailStatus.loading ||
      status == LessonDetailStatus.initial;

  bool get hasFailed => status == LessonDetailStatus.failure;

  bool get canPlay => playbackUrl != null;

  bool get isArticleRead => progress.isCompleted;

  List<int> get checkpoints => detail?.checkpoints ?? const <int>[];

  bool get hasReportedEveryCheckpoint =>
      checkpoints.isNotEmpty && checkpointIndex >= checkpoints.length;

  int? get nextCheckpointSeconds => checkpointIndex < checkpoints.length
      ? checkpoints[checkpointIndex]
      : null;

  int get seekLimitSeconds => positionSeconds > progress.maxPositionSeconds
      ? positionSeconds
      : progress.maxPositionSeconds;

  /// Furthest second reached on this device, including seconds watched since
  /// the last acknowledged checkpoint.
  ///
  /// Deliberately separate from [seekLimitSeconds]: that one answers "how far
  /// may the user scrub", this one answers "how far have they watched". They
  /// happen to share a formula today — changing the seek policy must not
  /// silently change what the progress bar shows.
  int get watchedHighWaterSeconds =>
      positionSeconds > progress.maxPositionSeconds
      ? positionSeconds
      : progress.maxPositionSeconds;

  /// Progress the server has actually credited. The only value that may inform
  /// what gets reported, unlocked, or marked complete.
  double get confirmedProgress => progress.progress;

  /// Optimistic progress derived from local playback, for display only.
  ///
  /// Checkpoints sit at quartiles of the duration, so on long lessons the
  /// credited percent can sit still for a very long time. This fills the gap
  /// between checkpoints; it is never sent anywhere.
  double get localProgress {
    final int total = detail?.durationSeconds ?? 0;
    if (total <= 0) return confirmedProgress;

    return (watchedHighWaterSeconds / total).clamp(0.0, 1.0);
  }

  /// What the progress bar renders. Never falls below [confirmedProgress], so
  /// a rejected seek pulls it back down to whatever the server credited.
  double get displayProgress {
    if (progress.isCompleted) return 1;

    return localProgress > confirmedProgress
        ? localProgress
        : confirmedProgress;
  }

  Duration get seekLimit => Duration(seconds: seekLimitSeconds);

  int get resumeSeconds => positionSeconds > progress.maxPositionSeconds
      ? positionSeconds
      : progress.maxPositionSeconds;

  bool isAttachmentDownloaded(int attachmentId) =>
      downloadedAttachmentIds.contains(attachmentId);

  LessonDetailState copyWith({
    LessonDetailStatus? status,
    LessonDetailModel? detail,
    LessonProgressModel? progress,
    bool? isLocked,
    String? playbackUrl,
    MediaSource? playbackSource,
    bool? isPreparingPlayback,
    bool? isPlaying,
    bool? isVideoFullscreen,
    int? positionSeconds,
    int? checkpointIndex,
    int? watchedDeltaSeconds,
    int? correctionSeconds,
    int? correctionRevision,
    int? downloadingAttachmentId,
    int? previewingAttachmentId,
    Set<int>? downloadedAttachmentIds,
    bool clearAttachmentBusy = false,
    String? errorKey,
    String? errorMessage,
    String? messageKey,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) => LessonDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    progress: progress ?? this.progress,
    isLocked: isLocked ?? this.isLocked,
    playbackUrl: playbackUrl ?? this.playbackUrl,
    playbackSource: playbackSource ?? this.playbackSource,
    isPreparingPlayback: isPreparingPlayback ?? this.isPreparingPlayback,
    isPlaying: isPlaying ?? this.isPlaying,
    isVideoFullscreen: isVideoFullscreen ?? this.isVideoFullscreen,
    positionSeconds: positionSeconds ?? this.positionSeconds,
    checkpointIndex: checkpointIndex ?? this.checkpointIndex,
    watchedDeltaSeconds: watchedDeltaSeconds ?? this.watchedDeltaSeconds,
    correctionSeconds: correctionSeconds ?? this.correctionSeconds,
    correctionRevision: correctionRevision ?? this.correctionRevision,
    downloadingAttachmentId: clearAttachmentBusy
        ? null
        : downloadingAttachmentId ?? this.downloadingAttachmentId,
    previewingAttachmentId: clearAttachmentBusy
        ? null
        : previewingAttachmentId ?? this.previewingAttachmentId,
    downloadedAttachmentIds:
        downloadedAttachmentIds ?? this.downloadedAttachmentIds,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    messageKey: clearMessage ? null : messageKey,
    message: clearMessage ? null : message,
  );
}
