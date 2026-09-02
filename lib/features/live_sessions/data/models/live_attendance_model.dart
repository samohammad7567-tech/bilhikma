import '../../../../core/network/json_reader.dart';

class LiveAttendanceModel {
  const LiveAttendanceModel({
    this.id,
    this.joinedAt,
    this.leftAt,
    this.totalSeconds = 0,
    this.lastHeartbeatAt,
    this.youtubeUrl,
  });

  final int? id;
  final DateTime? joinedAt;

  final DateTime? leftAt;
  final int totalSeconds;
  final DateTime? lastHeartbeatAt;

  final String? youtubeUrl;

  Duration get total => Duration(seconds: totalSeconds);

  bool get isActive => joinedAt != null && leftAt == null;

  factory LiveAttendanceModel.fromData(Map<String, dynamic> data) =>
      LiveAttendanceModel(
        id: Json.asOptionalInt(data['id']),
        joinedAt: Json.asDateTime(data['joined_at']),
        leftAt: Json.asDateTime(data['left_at']),
        totalSeconds: Json.asInt(data['total_seconds']),
        lastHeartbeatAt: Json.asDateTime(data['last_heartbeat_at']),
        youtubeUrl: Json.asOptionalString(data['youtube_url']),
      );
}
