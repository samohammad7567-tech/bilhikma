import 'package:flutter/material.dart';

import '../screen_wake_service.dart';
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
  static const double fallbackAspectRatio = 16 / 9;

  final VideoItem item;

  bool get isReady;

  bool get isPlaying;
  bool get isBuffering;

  bool get isLive;

  Duration get position;

  Duration get duration;

  double get playbackSpeed;
  @protected
  double get reportedAspectRatio;
  double get aspectRatio {
    final double ratio = reportedAspectRatio;

    return ratio.isFinite && ratio > 0 ? ratio : fallbackAspectRatio;
  }

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

  /// Whether the display should be held awake while this source plays.
  ///
  /// True for both kinds: a lesson is watched or listened to without the
  /// screen being touched, so the OS display timeout would otherwise fire
  /// mid-playback. Override in a subclass to opt a source out.
  @protected
  bool get keepsScreenAwake => true;

  /// Every state change from both subclasses funnels through here, which makes
  /// it the one place that can keep the wakelock in step with [isPlaying] —
  /// held while playing, released on pause, end, error and teardown.
  @override
  void notifyListeners() {
    ScreenWakeService.request(this, keepAwake: keepsScreenAwake && isPlaying);
    super.notifyListeners();
  }

  @override
  void dispose() {
    ScreenWakeService.release(this);
    super.dispose();
  }
}
