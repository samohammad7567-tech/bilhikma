import 'dart:io';

class DownloadLogItem {
  const DownloadLogItem({
    required this.filePath,
    required this.fileName,
    required this.sizeBytes,
    required this.modifiedAt,
    this.resumeKey,
  });

  factory DownloadLogItem.fromFile(File file, {String? resumeKey}) {
    final FileStat stat = file.statSync();

    return DownloadLogItem(
      filePath: file.path,
      fileName: file.uri.pathSegments.last,
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
      resumeKey: resumeKey,
    );
  }

  final String filePath;

  final String fileName;

  final int sizeBytes;

  final DateTime modifiedAt;

  final String? resumeKey;

  String get title => fileName.toLowerCase().endsWith('.pdf')
      ? fileName.substring(0, fileName.length - 4)
      : fileName;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).round()} KB';

    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
