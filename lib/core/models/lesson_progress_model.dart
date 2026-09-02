import '../network/json_reader.dart';

class LessonProgressModel {
  const LessonProgressModel({
    this.maxPositionSeconds = 0,
    this.watchedSeconds = 0,
    this.progressPercent = 0,
    this.isCompleted = false,
    this.allowedPositionSeconds,
  });

  final int maxPositionSeconds;

  final int watchedSeconds;
  final int progressPercent;
  final bool isCompleted;

  final int? allowedPositionSeconds;

  Duration get maxPosition => Duration(seconds: maxPositionSeconds);
  Duration get watched => Duration(seconds: watchedSeconds);

  Duration get allowedPosition =>
      Duration(seconds: allowedPositionSeconds ?? maxPositionSeconds);

  double get progress => (progressPercent / 100).clamp(0.0, 1.0);

  bool get isStarted => watchedSeconds > 0 || maxPositionSeconds > 0;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      LessonProgressModel(
        maxPositionSeconds: Json.asInt(json['max_position_seconds']),
        watchedSeconds: Json.asInt(json['watched_seconds']),
        progressPercent: Json.asInt(json['progress_percent']),
        isCompleted: Json.asBool(json['is_completed']),
        allowedPositionSeconds: Json.asOptionalInt(
          json['allowed_position_seconds'],
        ),
      );
}

class ProgressHeartbeatRequestModel {
  const ProgressHeartbeatRequestModel({
    required this.positionSeconds,
    this.watchedDeltaSeconds = 0,
  });

  static const int maxWatchedDeltaSeconds = 3600;

  final int positionSeconds;

  final int watchedDeltaSeconds;

  int get _position => positionSeconds < 0 ? 0 : positionSeconds;

  int get _delta {
    if (watchedDeltaSeconds < 0) return 0;
    if (watchedDeltaSeconds > maxWatchedDeltaSeconds) {
      return maxWatchedDeltaSeconds;
    }
    return watchedDeltaSeconds;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'position_seconds': _position,
    'watched_delta_seconds': _delta,
  };
}
