import 'dart:io';

import '../../../../core/utils/error_mapper.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../models/download_log_item.dart';

class DownloadsLogDataSource {
  const DownloadsLogDataSource({
    this.downloads = const DownloadedPdfsDataSource(),
  });

  final DownloadedPdfsDataSource downloads;

  Future<List<DownloadLogItem>> readDownloads() async {
    try {
      final List<File> files = await downloads.listFiles();

      return files.map((File file) {
        final String name = file.uri.pathSegments.last;

        return DownloadLogItem.fromFile(
          file,
          resumeKey: downloads.keyForFile(name),
        );
      }).toList();
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  Future<void> deleteDownload(String fileName) async {
    try {
      await downloads.deleteFileNamed(fileName);
    } catch (error) {
      throw AppException(_keyFor(error, 'download_delete_failed'));
    }
  }

  Future<void> deleteAllDownloads() async {
    try {
      await downloads.clearAll();
    } catch (error) {
      throw AppException(_keyFor(error, 'downloads_clear_failed'));
    }
  }

  String _keyFor(Object error, String fallbackKey) =>
      error is AppException ? error.key : fallbackKey;
}
