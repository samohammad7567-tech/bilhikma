import '../../../../core/network/json_reader.dart';
import '../../../../core/enums/content_type_enum.dart';

class ResumeLessonModel {
  const ResumeLessonModel({
    required this.contentId,
    required this.title,
    required this.type,
    this.subjectName = '',
    this.durationSeconds = 0,
    this.resumeAtSeconds = 0,
    this.progressPercent = 0,
    this.lastSeenAt,
  });

  final int contentId;
  final String title;
  final ContentType type;
  final String subjectName;
  final int durationSeconds;

  final int resumeAtSeconds;
  final int progressPercent;
  final DateTime? lastSeenAt;

  Duration get duration => Duration(seconds: durationSeconds);
  Duration get resumeAt => Duration(seconds: resumeAtSeconds);

  Duration get remaining {
    final int left = durationSeconds - resumeAtSeconds;
    return Duration(seconds: left < 0 ? 0 : left);
  }

  double get progress => (progressPercent / 100).clamp(0.0, 1.0);

  factory ResumeLessonModel.fromJson(Map<String, dynamic> json) =>
      ResumeLessonModel(
        contentId: Json.asInt(json['content_id']),
        title: Json.asLocalizedString(json['title']),
        type: ContentType.fromJson(json['type']),
        subjectName: Json.asLocalizedString(json['subject_name']),
        durationSeconds: Json.asInt(json['duration_seconds']),
        resumeAtSeconds: Json.asInt(json['resume_at_seconds']),
        progressPercent: Json.asInt(json['progress_percent']),
        lastSeenAt: Json.asDateTime(json['last_seen_at']),
      );
}
