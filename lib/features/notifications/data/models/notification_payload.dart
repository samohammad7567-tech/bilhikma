import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/network/json_reader.dart';

class NotificationPayload {
  const NotificationPayload({
    this.contentId = 0,
    this.contentType = ContentType.video,
    this.liveSessionId = 0,
    this.categorySubjectId = 0,
    this.attemptId = 0,
    this.quizId = 0,
    this.action,
    this.autoSubmitted = false,
    this.notificationId = 0,
  });

  final int contentId;
  final ContentType contentType;

  final int liveSessionId;
  final int categorySubjectId;

  final int attemptId;
  final int quizId;
  final String? action;
  final bool autoSubmitted;
  final int notificationId;

  static const NotificationPayload none = NotificationPayload();

  bool get hasContent => contentId > 0;

  bool get hasLiveSession => liveSessionId > 0;

  bool get hasSubject => categorySubjectId > 0;

  bool get hasQuizResult =>
      (contentId > 0 || quizId > 0) &&
      (attemptId > 0 ||
          (action ?? '')
              .toLowerCase()
              .replaceAll('-', '_')
              .contains('quiz_result'));

  bool get hasTarget => hasContent || hasLiveSession || hasSubject;

  factory NotificationPayload.fromJson(Object? raw) {
    if (raw is! Map) return none;

    final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
    final int attemptId = Json.asInt(
      data['attempt_id'] ?? data['quiz_attempt_id'],
    );
    final String? type = Json.asOptionalString(data['type'] ?? data['kind']);
    final String? action = Json.asOptionalString(data['action']);
    final bool isQuizResultType =
        type != null &&
        type.toLowerCase().contains('quiz') &&
        (type.toLowerCase().contains('result') ||
            type.toLowerCase().contains('attempt'));

    return NotificationPayload(
      contentId: Json.asInt(data['content_id'] ?? data['lesson_id']),
      contentType: ContentType.fromJson(data['content_type']),
      liveSessionId: Json.asInt(data['live_session_id']),
      categorySubjectId: Json.asInt(data['category_subject_id']),
      attemptId: attemptId,
      quizId: Json.asInt(data['quiz_id']),
      action: action ?? (isQuizResultType ? 'open_quiz_result' : null),
      autoSubmitted: Json.asBool(data['auto_submitted']),
      notificationId: Json.asInt(data['notification_id'] ?? data['id']),
    );
  }
}
