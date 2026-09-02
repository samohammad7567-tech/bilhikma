import 'package:flutter/material.dart';

import 'network_video_playback.dart';
import 'video_item.dart';
import 'youtube_video_playback.dart';
import '../../enums/video_source_kind_enum.dart';

abstract class VideoPlayback extends ChangeNotifier {
  VideoPlayback(this.item);

  factory VideoPlayback.forItem(VideoItem item) => switch (item.kind) {
    VideoSourceKind.youtube => YoutubeVideoPlayback(item),
    VideoSourceKind.network => NetworkVideoPlayback(item),
  };

  final VideoItem item;

  bool get isReady;

  bool get isPlaying;
  bool get isBuffering;

  bool get isLive;

  Duration get position;

  Duration get duration;

  double get playbackSpeed;

  double get aspectRatio;

  String? get errorMessage;

  bool get canSeek => !isLive && duration > Duration.zero;

  Future<void> initialize();

  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration target);
  Future<void> setPlaybackSpeed(double speed);

  Future<void> togglePlayPause() => isPlaying ? pause() : play();

  Future<void> seekBy(Duration delta) {
    if (!canSeek) return Future<void>.value();

    Duration target = position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;

    return seekTo(target);
  }

  Widget buildSurface({Key? key, Widget? overlay});
}
