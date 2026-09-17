import 'dart:io';

import '../../../../core/models/lesson_progress_model.dart';
import '../data_source/lesson_detail_data_source.dart';
import '../models/lesson_attachment_model.dart';
import '../models/lesson_detail_model.dart';

class LessonDetailRepo {
  LessonDetailRepo({LessonDetailDataSource? dataSource})
    : dataSource = dataSource ?? LessonDetailDataSource();

  final LessonDetailDataSource dataSource;

  Future<LessonDetailModel> fetchLesson(int contentId) =>
      dataSource.fetchLesson(contentId);

  Future<PlaybackAccess> requestPlayback(int contentId) =>
      dataSource.requestPlayback(contentId);

  Future<String> requestAttachmentUrl(int contentId, int attachmentId) =>
      dataSource.requestAttachmentUrl(contentId, attachmentId);

  Future<File> downloadAttachment(int contentId, LessonAttachmentModel file) =>
      dataSource.downloadAttachment(contentId, file);

  Future<File> fetchAttachmentForPreview(
    int contentId,
    LessonAttachmentModel file,
  ) => dataSource.fetchAttachmentForPreview(contentId, file);

  Future<Set<int>> downloadedAttachmentIds(
    int contentId,
    Iterable<int> attachmentIds,
  ) => dataSource.downloadedAttachmentIds(contentId, attachmentIds);

  Future<ProgressResult> reportProgress(
    int contentId,
    ProgressHeartbeatRequestModel request,
  ) => dataSource.reportProgress(contentId, request);
}
