import '../enums/content_type_enum.dart';
import '../enums/lesson_status_enum.dart';
import '../network/json_reader.dart';
import '../../features/lesson_detail/data/models/quiz_summary_model.dart';
import 'lesson_progress_model.dart';

class LessonModel {
  const LessonModel({
    required this.id,
    required this.categorySubjectId,
    required this.title,
    required this.type,
    this.description,
    this.durationSeconds = 0,
    this.order = 0,
    this.thumbnailUrl,
    this.isLocked = false,
    this.checkpoints = const <int>[],
    this.isProtectedMedia = false,
    this.publishedAt,
    this.progress = const LessonProgressModel(),
    this.quiz,
  });

  final int id;

  final int categorySubjectId;
  final String title;
  final ContentType type;

  final String? description;

  final int durationSeconds;
  final int order;
  final String? thumbnailUrl;

  final bool isLocked;

  final List<int> checkpoints;

  final bool isProtectedMedia;
  final DateTime? publishedAt;
  final LessonProgressModel progress;
  final QuizSummaryModel? quiz;

  bool get hasQuiz => quiz != null;

  Duration get duration => Duration(seconds: durationSeconds);

  LessonStatus get status => LessonStatus.resolve(
    isCompleted: progress.isCompleted,
    isStarted: progress.isStarted,
    isLocked: isLocked,
  );

  static QuizSummaryModel? _quizFromJson(Object? value) {
    final Map<String, dynamic>? quiz = Json.asOptionalMap(value);
    return quiz == null ? null : QuizSummaryModel.fromJson(quiz);
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
    id: Json.asInt(json['id']),
    categorySubjectId: Json.asInt(json['category_subject_id']),
    title: Json.asLocalizedString(json['title']),
    type: ContentType.fromJson(json['type']),
    description: Json.asOptionalLocalizedString(json['description']),
    durationSeconds: Json.asInt(json['duration_seconds']),
    order: Json.asInt(json['order']),
    thumbnailUrl: Json.asOptionalString(json['thumbnail_url']),
    isLocked: Json.asBool(json['is_locked']),
    checkpoints: Json.asIntList(json['checkpoints']),
    isProtectedMedia: Json.asBool(json['is_protected_media']),
    publishedAt: Json.asDateTime(json['published_at']),
    progress: LessonProgressModel.fromJson(Json.asMap(json['progress'])),
    quiz: _quizFromJson(json['quiz']),
  );
}
