import '../../../../core/network/json_reader.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_progress_model.dart';
import '../../../../core/enums/lesson_status_enum.dart';
import 'lesson_attachment_model.dart';

class LessonDetailModel {
  const LessonDetailModel({
    required this.id,
    required this.title,
    required this.type,
    this.categorySubjectId = 0,
    this.description,
    this.subjectName,
    this.publishedAt,
    this.durationSeconds = 0,
    this.thumbnailUrl,
    this.isLocked = false,
    this.checkpoints = const <int>[],
    this.isProtectedMedia = false,
    this.articleBody,
    this.attachments = const <LessonAttachmentModel>[],
    this.progress = const LessonProgressModel(),
  });

  final int id;
  final int categorySubjectId;
  final String title;
  final ContentType type;
  final String? description;

  final String? subjectName;
  final DateTime? publishedAt;
  final int durationSeconds;
  final String? thumbnailUrl;

  final bool isLocked;

  final List<int> checkpoints;

  final bool isProtectedMedia;

  final String? articleBody;
  final List<LessonAttachmentModel> attachments;
  final LessonProgressModel progress;

  Duration get duration => Duration(seconds: durationSeconds);

  bool get isArticle => type.isArticle;
  bool get isVideo => type.isVideo;
  bool get isAudio => type.isAudio;

  bool get isPlayable => type.isPlayable;

  bool get hasAttachments => attachments.isNotEmpty;

  bool get hasCheckpoints => checkpoints.isNotEmpty;

  LessonStatus get status => LessonStatus.resolve(
    isCompleted: progress.isCompleted,
    isStarted: progress.isStarted,
    isLocked: isLocked,
  );

  Duration get resumeAt => progress.allowedPosition;

  Duration get remaining {
    final int left = durationSeconds - progress.maxPositionSeconds;
    return Duration(seconds: left < 0 ? 0 : left);
  }

  factory LessonDetailModel.fromData(Map<String, dynamic> data) =>
      LessonDetailModel(
        id: Json.asInt(data['id']),
        categorySubjectId: Json.asInt(data['category_subject_id']),
        title: Json.asString(data['title']),
        type: ContentType.fromJson(data['type']),
        description: Json.asOptionalString(data['description']),
        subjectName: Json.asOptionalString(data['subject_name']),
        publishedAt: Json.asDateTime(data['published_at']),
        durationSeconds: Json.asInt(data['duration_seconds']),
        thumbnailUrl: Json.asOptionalString(data['thumbnail_url']),
        isLocked: Json.asBool(data['is_locked']),
        checkpoints: Json.asIntList(data['checkpoints']),
        isProtectedMedia: Json.asBool(data['is_protected_media']),
        articleBody: Json.asOptionalString(data['article_body']),
        attachments: Json.asList<LessonAttachmentModel>(
          data['attachments'],
          LessonAttachmentModel.fromJson,
        ),
        progress: LessonProgressModel.fromJson(Json.asMap(data['progress'])),
      );
}
