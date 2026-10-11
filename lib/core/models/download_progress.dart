import '../utils/byte_format.dart';

/// Bytes streamed so far for a single file download.
///
/// [total] is the `Content-Length` the server reported, or the size the API
/// already published for the file when the response carries no length.
class DownloadProgress {
  const DownloadProgress({this.received = 0, this.total = 0});

  final int received;
  final int total;

  static const DownloadProgress none = DownloadProgress();

  bool get isDeterminate => total > 0;

  bool get hasStarted => received > 0 || isDeterminate;

  /// Null while the total size is unknown, so the bar can spin instead.
  double? get fraction {
    if (!isDeterminate) return null;

    return (received / total).clamp(0.0, 1.0);
  }

  int get percent => ((fraction ?? 0) * 100).floor();

  /// `2.4 / 12.0 MB` — both sides share the unit of the larger value.
  String get readableRatio {
    if (!isDeterminate) return ByteFormat.readable(received);

    final String done = ByteFormat.readableValue(
      received.clamp(0, total),
      referenceBytes: total,
    );

    return '$done / ${ByteFormat.readable(total)}';
  }

  DownloadProgress withTotalFallback(int fallback) =>
      isDeterminate || fallback <= 0
      ? this
      : DownloadProgress(received: received, total: fallback);
}
