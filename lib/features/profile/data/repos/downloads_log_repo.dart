import '../data_source/downloads_log_data_source.dart';
import '../models/download_log_item.dart';

class DownloadsLogRepo {
  const DownloadsLogRepo({this.dataSource = const DownloadsLogDataSource()});

  final DownloadsLogDataSource dataSource;

  Future<List<DownloadLogItem>> readDownloads() => dataSource.readDownloads();

  Future<void> deleteDownload(String fileName) =>
      dataSource.deleteDownload(fileName);

  Future<void> deleteAllDownloads() => dataSource.deleteAllDownloads();
}
