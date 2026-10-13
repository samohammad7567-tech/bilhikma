import '../enums/download_phase_enum.dart';
import 'download_progress.dart';

/// One file download as the UI needs to see it: how far it has come, and
/// whether it ended in success or failure.
class FileDownloadState {
  const FileDownloadState({
    required this.phase,
    this.progress = DownloadProgress.none,
    this.errorKey,
  });

  final DownloadPhase phase;
  final DownloadProgress progress;

  /// Localization key for the failure reason, set only when [phase] failed.
  final String? errorKey;

  /// A download that has been requested but has not reported any bytes yet.
  factory FileDownloadState.starting({int expectedBytes = 0}) =>
      FileDownloadState(
        phase: DownloadPhase.downloading,
        progress: DownloadProgress(
          total: expectedBytes > 0 ? expectedBytes : 0,
        ),
      );

  factory FileDownloadState.running(DownloadProgress progress) =>
      FileDownloadState(phase: DownloadPhase.downloading, progress: progress);

  factory FileDownloadState.failed(String errorKey) =>
      FileDownloadState(phase: DownloadPhase.failed, errorKey: errorKey);

  static const FileDownloadState completed = FileDownloadState(
    phase: DownloadPhase.completed,
    progress: DownloadProgress(received: 1, total: 1),
  );

  bool get isDownloading => phase.isDownloading;

  bool get isCompleted => phase.isCompleted;

  bool get isFailed => phase.isFailed;
}
