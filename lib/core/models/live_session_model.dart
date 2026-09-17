import '../enums/live_session_status_enum.dart';
import '../network/json_reader.dart';

class LiveSessionModel {
  const LiveSessionModel({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.youtubeUrl,
    this.scheduledAt,
    this.reminderMinutesBefore,
    this.status = LiveSessionStatus.scheduled,
    this.isUpcoming = false,
    this.isLive = false,
    this.isEnded = false,
  });

  final int id;
  final String title;
  final String? description;

  final String? coverUrl;

  final String? youtubeUrl;
  final DateTime? scheduledAt;

  final int? reminderMinutesBefore;
  final LiveSessionStatus status;
  final bool isUpcoming;

  final bool isLive;
  final bool isEnded;

  bool get isPlayable => isLive && (youtubeUrl ?? '').isNotEmpty;

  Duration? get startsIn {
    final DateTime? at = scheduledAt;
    if (at == null || !isUpcoming) return null;

    final Duration left = at.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) =>
      LiveSessionModel(
        id: Json.asInt(json['id']),
        title: Json.asLocalizedString(json['title']),
        description: Json.asOptionalLocalizedString(json['description']),
        coverUrl: Json.asOptionalString(json['cover_url']),
        youtubeUrl: Json.asOptionalString(json['youtube_url']),
        scheduledAt: Json.asDateTime(json['scheduled_at']),
        reminderMinutesBefore: Json.asOptionalInt(
          json['reminder_minutes_before'],
        ),
        status: LiveSessionStatus.fromJson(json['status']),
        isUpcoming: Json.asBool(json['is_upcoming']),
        isLive: Json.asBool(json['is_live']),
        isEnded: Json.asBool(json['is_ended']),
      );
}
