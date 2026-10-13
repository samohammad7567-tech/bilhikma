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
    this.playbackSpeed = PlaybackSpeed.normal,
    this.positionSeconds = 0,
    this.checkpointIndex = 0,
    this.watchedDeltaSeconds = 0,
    this.correctionSeconds,
    this.correctionRevision = 0,
    this.downloadingAttachmentId,
    this.previewingAttachmentId,
    this.downloadedAttachmentIds = const <int>{},
    this.attachmentDownloads = const <int, FileDownloadState>{},
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

  final PlaybackSpeed playbackSpeed;

  final int positionSeconds;

  final int checkpointIndex;

  final int watchedDeltaSeconds;

  final int? correctionSeconds;
  final int correctionRevision;

  final int? downloadingAttachmentId;
  final int? previewingAttachmentId;

  final Set<int> downloadedAttachmentIds;

  /// Live download state per attachment id: running progress, or the
  /// completed / failed outcome of the last attempt.
  final Map<int, FileDownloadState> attachmentDownloads;

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
  PlaybackSpeed get effectivePlaybackSpeed => playbackSpeed.cappedFor(
    isLessonCompleted: progress.isCompleted,
    isLowEndDevice: DeviceInfoService.isLowEndDevice,
  );

  List<int> get checkpoints => detail?.checkpoints ?? const <int>[];

  int? get nextCheckpointSeconds => checkpointIndex < checkpoints.length
      ? checkpoints[checkpointIndex]
      : null;
  int get seekLimitSeconds {
    if (progress.isCompleted) {
      final int total = detail?.durationSeconds ?? 0;
      if (total > watchedHighWaterSeconds) return total;
    }

    return watchedHighWaterSeconds;
  }

  int get watchedHighWaterSeconds =>
      positionSeconds > progress.maxPositionSeconds
      ? positionSeconds
      : progress.maxPositionSeconds;
  static const double _unconfirmedCeiling = 0.99;
  double get confirmedProgress =>
      progress.isCompleted ? 1 : _capped(progress.progress);
  double get localProgress {
    final int total = detail?.durationSeconds ?? 0;
    if (total <= 0) return confirmedProgress;

    return _capped((watchedHighWaterSeconds / total).clamp(0.0, 1.0));
  }

  double get displayProgress {
    if (progress.isCompleted) return 1;

    return localProgress > confirmedProgress
        ? localProgress
        : confirmedProgress;
  }

  static double _capped(double value) =>
      value > _unconfirmedCeiling ? _unconfirmedCeiling : value;

  Duration get seekLimit => Duration(seconds: seekLimitSeconds);
  int get resumeSeconds => positionSeconds;

  bool isAttachmentDownloaded(int attachmentId) =>
      downloadedAttachmentIds.contains(attachmentId);

  FileDownloadState? attachmentDownloadFor(int attachmentId) =>
      attachmentDownloads[attachmentId];

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
    PlaybackSpeed? playbackSpeed,
    int? positionSeconds,
    int? checkpointIndex,
    int? watchedDeltaSeconds,
    int? correctionSeconds,
    int? correctionRevision,
    int? downloadingAttachmentId,
    int? previewingAttachmentId,
    Set<int>? downloadedAttachmentIds,
    Map<int, FileDownloadState>? attachmentDownloads,
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
    playbackSpeed: playbackSpeed ?? this.playbackSpeed,
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
    attachmentDownloads: attachmentDownloads ?? this.attachmentDownloads,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    messageKey: clearMessage ? null : messageKey,
    message: clearMessage ? null : message,
  );
}
