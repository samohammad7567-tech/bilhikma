import '../../../../core/network/json_reader.dart';

class LessonPlaybackStateModel {
  const LessonPlaybackStateModel({
    required this.contentId,
    this.positionSeconds = 0,
    this.watchedDeltaSeconds = 0,
    this.nextCheckpointIndex = 0,
  });

  final int contentId;

  final int positionSeconds;

  final int watchedDeltaSeconds;

  final int nextCheckpointIndex;

  LessonPlaybackStateModel copyWith({
    int? positionSeconds,
    int? watchedDeltaSeconds,
    int? nextCheckpointIndex,
  }) => LessonPlaybackStateModel(
    contentId: contentId,
    positionSeconds: positionSeconds ?? this.positionSeconds,
    watchedDeltaSeconds: watchedDeltaSeconds ?? this.watchedDeltaSeconds,
    nextCheckpointIndex: nextCheckpointIndex ?? this.nextCheckpointIndex,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'content_id': contentId,
    'position_seconds': positionSeconds,
    'watched_delta_seconds': watchedDeltaSeconds,
    'next_checkpoint_index': nextCheckpointIndex,
  };

  factory LessonPlaybackStateModel.fromJson(Map<String, dynamic> json) =>
      LessonPlaybackStateModel(
        contentId: Json.asInt(json['content_id']),
        positionSeconds: Json.asInt(json['position_seconds']),
        watchedDeltaSeconds: Json.asInt(json['watched_delta_seconds']),
        nextCheckpointIndex: Json.asInt(json['next_checkpoint_index']),
      );
}
