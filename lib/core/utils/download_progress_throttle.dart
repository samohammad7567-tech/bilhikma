import '../models/download_progress.dart';

class DownloadProgressThrottle {
  DownloadProgressThrottle({this.byteStep = 256 * 1024});
  final int byteStep;

  int _percent = -1;
  int _received = -1;

  void reset() {
    _percent = -1;
    _received = -1;
  }

  bool shouldEmit(DownloadProgress progress) {
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
