import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/network/media_access_model.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/lesson_progress_model.dart';
import '../../../../core/services/prd_services.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../models/lesson_attachment_model.dart';
import '../models/lesson_detail_model.dart';

class ProgressResult {
  const ProgressResult({
    this.progress,
    this.allowedPositionSeconds,
    this.seekRejected = false,
  });

  final LessonProgressModel? progress;

  final int? allowedPositionSeconds;

  final bool seekRejected;
}

class LessonDetailDataSource {
  LessonDetailDataSource({
    this.client = const ApiClient(),
    this.downloads = const DownloadedPdfsDataSource(),
    PdfService? pdf,
  }) : pdf = pdf ?? PdfService();

  final ApiClient client;
  final PdfService pdf;
  final DownloadedPdfsDataSource downloads;

  Future<LessonDetailModel> fetchLesson(int contentId) =>
      client.getObject<LessonDetailModel>(
        ApiEndpoints.contentDetail(contentId),
        LessonDetailModel.fromData,
      );

  Future<String> requestPlaybackUrl(int contentId) async {
    final MediaAccessModel access = await requestPlaybackToken(contentId);
    return access.url(deviceUuid: DeviceService.deviceUuid);
  }

  Future<MediaAccessModel> requestPlaybackToken(int contentId) async {
    await DeviceService.ensureInitialized();

    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.contentAccessToken(contentId),
      data: <String, dynamic>{'device_uuid': DeviceService.deviceUuid},
    );

    return MediaAccessModel.fromJson(envelope.dataMap);
  }

  Future<String> requestAttachmentUrl(int contentId, int attachmentId) async {
    await DeviceService.ensureInitialized();

    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.attachmentAccessToken(contentId, attachmentId),
      data: <String, dynamic>{'device_uuid': DeviceService.deviceUuid},
    );

    return MediaAccessModel.fromJson(
      envelope.dataMap,
    ).url(deviceUuid: DeviceService.deviceUuid);
  }

  Future<File> downloadAttachment(
    int contentId,
    LessonAttachmentModel file,
  ) async {
    final String url = await requestAttachmentUrl(contentId, file.id);

    final File saved = await _fetch(
      () => pdf.downloadPdf(pdfUrl: url, fileName: file.fileName),
    );

    await downloads.remember(
      DownloadedPdfsDataSource.attachmentKey(contentId, file.id),
      saved,
    );

    return saved;
  }

  Future<File> fetchAttachmentForPreview(
    int contentId,
    LessonAttachmentModel file,
  ) async {
    final File? saved = await downloads.fileFor(
      DownloadedPdfsDataSource.attachmentKey(contentId, file.id),
    );
    if (saved != null) return saved;

    final String url = await requestAttachmentUrl(contentId, file.id);

    return _fetch(
      () => pdf.downloadToCache(pdfUrl: url, fileName: file.fileName),
    );
  }

  Future<Set<int>> downloadedAttachmentIds(
    int contentId,
    Iterable<int> attachmentIds,
  ) async {
    final Set<String> keys = await downloads.available(
      attachmentIds.map(
        (int id) => DownloadedPdfsDataSource.attachmentKey(contentId, id),
      ),
    );

    return attachmentIds
        .where(
          (int id) => keys.contains(
            DownloadedPdfsDataSource.attachmentKey(contentId, id),
          ),
        )
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

  Future<ProgressResult> reportProgress(
    int contentId,
    ProgressHeartbeatRequestModel request,
  ) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.contentProgress(contentId),
        data: request.toJson(),
      );

      return ProgressResult(
        progress: LessonProgressModel.fromJson(envelope.dataMap),
      );
    } on AppException catch (error) {
      if (error.statusCode != 422) rethrow;

      final Map<String, dynamic> body = Json.asMap(error.data);

      return ProgressResult(
        progress: body.isEmpty ? null : LessonProgressModel.fromJson(body),
        allowedPositionSeconds: Json.asOptionalInt(
          body['allowed_position_seconds'],
        ),
        seekRejected: true,
      );
    }
  }
}
