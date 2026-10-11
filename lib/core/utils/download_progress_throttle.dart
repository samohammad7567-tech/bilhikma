import '../models/download_progress.dart';

/// Drops progress ticks that would not change what the user sees.
///
/// Dio fires one callback per received chunk, which is far more often than a
/// bar needs to repaint — and every tick that reaches a cubit is a rebuild.
class DownloadProgressThrottle {
  DownloadProgressThrottle({this.byteStep = 256 * 1024});

  /// Bytes between ticks while the total size is unknown.
  final int byteStep;

  int _percent = -1;
  int _received = -1;

  void reset() {
    _percent = -1;
    _received = -1;
  }

  bool shouldEmit(DownloadProgress progress) {
    // A retry on a fresh link restarts the transfer from zero.
    if (progress.received < _received) reset();

    if (progress.isDeterminate) {
      if (progress.percent == _percent) return false;

      _percent = progress.percent;
      _received = progress.received;
      return true;
    }

    if (progress.received - _received < byteStep) return false;

    _received = progress.received;
    return true;
  }
}
