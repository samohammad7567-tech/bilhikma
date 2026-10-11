import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/network/json_reader.dart';

/// The `data` object the API attaches to a notification.
///
/// `deep_link` comes back null on every notification the service sends, so
/// this is the only thing that says what a notification is actually about.
class NotificationPayload {
  const NotificationPayload({
    this.contentId = 0,
    this.contentType = ContentType.video,
    this.liveSessionId = 0,
    this.categorySubjectId = 0,
  });

  final int contentId;
  final ContentType contentType;

  final int liveSessionId;
  final int categorySubjectId;

  static const NotificationPayload none = NotificationPayload();

  bool get hasContent => contentId > 0;

  bool get hasLiveSession => liveSessionId > 0;

  bool get hasSubject => categorySubjectId > 0;

  /// True when the payload names something the app can open.
  bool get hasTarget => hasContent || hasLiveSession || hasSubject;

  factory NotificationPayload.fromJson(Object? raw) {
    if (raw is! Map) return none;

    final Map<String, dynamic> data = Map<String, dynamic>.from(raw);

    return NotificationPayload(
      contentId: Json.asInt(data['content_id']),
      contentType: ContentType.fromJson(data['content_type']),
      liveSessionId: Json.asInt(data['live_session_id']),
      categorySubjectId: Json.asInt(data['category_subject_id']),
    );
  }
}
