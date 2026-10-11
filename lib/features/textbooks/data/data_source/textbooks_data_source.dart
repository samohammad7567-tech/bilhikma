import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/media_access_model.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/prd_services.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/download_progress.dart';
import '../../../../core/models/textbook_model.dart';
import 'downloaded_pdfs_data_source.dart';

typedef DownloadProgressCallback = void Function(DownloadProgress progress);

class TextbooksDataSource {
  TextbooksDataSource({
    this.client = const ApiClient(),
    this.downloads = const DownloadedPdfsDataSource(),
    PdfService? pdf,
  }) : pdf = pdf ?? PdfService();

  final ApiClient client;
  final PdfService pdf;
  final DownloadedPdfsDataSource downloads;

  static const String _expiredKey = 'media_link_expired';

  Future<List<TextbookModel>> fetchTextbooks() async {
    final PaginatedResult<TextbookModel> page = await client
        .getPage<TextbookModel>(ApiEndpoints.textbooks, TextbookModel.fromJson);

    return page.items;
  }

  Future<String> requestDownloadUrl(int textbookId) async {
    await DeviceService.ensureInitialized();

    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.textbookDownload(textbookId),
      data: <String, dynamic>{'device_uuid': DeviceService.deviceUuid},
    );

    final MediaAccessModel access = MediaAccessModel.fromJson(envelope.dataMap);

    if (!access.isValid) {
      throw const AppException(_expiredKey);
    }

    return access.url(deviceUuid: DeviceService.deviceUuid);
  }

  Future<File> downloadTextbook(
    TextbookModel book, {
    DownloadProgressCallback? onProgress,
  }) async {
    final File file = await _downloadFreshLink(
      book,
      onProgress,
      (String url, ProgressCallback? progress) => pdf.downloadPdf(
        pdfUrl: url,
        fileName: book.title,
        onProgress: progress,
      ),
    );

    await downloads.remember(DownloadedPdfsDataSource.bookKey(book.id), file);

    return file;
  }

  Future<File> fetchForPreview(
    TextbookModel book, {
    DownloadProgressCallback? onProgress,
  }) async {
    final File? saved = await downloads.fileFor(
      DownloadedPdfsDataSource.bookKey(book.id),
    );
    if (saved != null) return saved;

    return _downloadFreshLink(
      book,
      onProgress,
      (String url, ProgressCallback? progress) => pdf.downloadToCache(
        pdfUrl: url,
        fileName: book.title,
        onProgress: progress,
      ),
    );
  }

  Future<Set<int>> downloadedBookIds(Iterable<int> bookIds) async {
    final Set<String> keys = await downloads.available(
      bookIds.map(DownloadedPdfsDataSource.bookKey),
    );

    return bookIds
        .where((int id) => keys.contains(DownloadedPdfsDataSource.bookKey(id)))
        .toSet();
  }

  /// Mints a signed link, then retries once on a fresh link when the first one
  /// expires mid transfer — large books on slow connections can outlive it.
  Future<File> _downloadFreshLink(
    TextbookModel book,
    DownloadProgressCallback? onProgress,
    Future<File> Function(String url, ProgressCallback? progress) run,
  ) async {
    final ProgressCallback? progress = _adapt(book, onProgress);

    final String url = await requestDownloadUrl(book.id);

    try {
      return await _fetch(() => run(url, progress));
    } on AppException catch (error) {
      if (error.key != _expiredKey) rethrow;

      onProgress?.call(DownloadProgress.none);

      final String fresh = await requestDownloadUrl(book.id);

      return _fetch(() => run(fresh, progress));
    }
  }

  /// Dio reports `-1` as the total when the response carries no
  /// `Content-Length`; the size the API published for the book stands in.
  ProgressCallback? _adapt(
    TextbookModel book,
    DownloadProgressCallback? onProgress,
  ) {
    if (onProgress == null) return null;

    return (int received, int total) => onProgress(
      DownloadProgress(
        received: received,
        total: total,
      ).withTotalFallback(book.fileSize),
    );
  }

  Future<T> _fetch<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        throw const AppException(_expiredKey, statusCode: 403);
      }
      throw ErrorMapper.toException(error);
    } catch (error) {
      throw ErrorMapper.toException(error);
    }
  }
}
