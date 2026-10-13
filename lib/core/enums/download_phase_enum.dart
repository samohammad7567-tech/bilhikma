enum DownloadPhase {
  downloading,
  completed,
  failed;

  bool get isDownloading => this == DownloadPhase.downloading;

  bool get isCompleted => this == DownloadPhase.completed;

  bool get isFailed => this == DownloadPhase.failed;

  bool get isFinished => !isDownloading;
}
