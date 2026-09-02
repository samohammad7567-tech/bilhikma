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
import '../../../../core/models/textbook_model.dart';
import 'downloaded_pdfs_data_source.dart';

class TextbooksDataSource {
  TextbooksDataSource({
    this.client = const ApiClient(),
    this.downloads = const DownloadedPdfsDataSource(),
    PdfService? pdf,
  }) : pdf = pdf ?? PdfService();

  final ApiClient client;
  final PdfService pdf;
  final DownloadedPdfsDataSource downloads;

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
      throw const AppException('media_link_expired');
    }

    return access.url(deviceUuid: DeviceService.deviceUuid);
  }

  Future<File> downloadTextbook(TextbookModel book) async {
    final String url = await requestDownloadUrl(book.id);

    final File file = await _fetch(
      () => pdf.downloadPdf(pdfUrl: url, fileName: book.title),
    );

    await downloads.remember(DownloadedPdfsDataSource.bookKey(book.id), file);

    return file;
  }

  Future<File> fetchForPreview(TextbookModel book) async {
    final File? saved = await downloads.fileFor(
      DownloadedPdfsDataSource.bookKey(book.id),
    );
    if (saved != null) return saved;

    final String url = await requestDownloadUrl(book.id);

    return _fetch(() => pdf.downloadToCache(pdfUrl: url, fileName: book.title));
  }

  Future<Set<int>> downloadedBookIds(Iterable<int> bookIds) async {
    final Set<String> keys = await downloads.available(
      bookIds.map(DownloadedPdfsDataSource.bookKey),
    );

    return bookIds
        .where((int id) => keys.contains(DownloadedPdfsDataSource.bookKey(id)))
        .toSet();
  }

  Future<T> _fetch<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        throw const AppException('media_link_expired', statusCode: 403);
      }
      throw ErrorMapper.toException(error);
    } catch (error) {
      throw ErrorMapper.toException(error);
    }
  }
}
