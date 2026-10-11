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

  /// Used until a real ratio is known, and whenever the reported one is
  /// unusable.
  static const double fallbackAspectRatio = 16 / 9;

  final VideoItem item;

  bool get isReady;

  bool get isPlaying;
  bool get isBuffering;

  bool get isLive;

  Duration get position;

  Duration get duration;

  double get playbackSpeed;

  /// The ratio the backend reports, unsanitised.
  ///
  /// Implementations are free to return whatever the player gives them: zero
  /// before a size is known, or `NaN`/`Infinity` for a stream that reports a
  /// malformed one. Use [aspectRatio] everywhere outside this class.
  @protected
  double get reportedAspectRatio;

  /// Ratio to lay the video surface out at — always finite and greater than
  /// zero.
  ///
  /// This guarantee is the point of the getter. Callers divide the screen
  /// width by it and hand it to [AspectRatio], and a zero or `NaN` in either
  /// position is a layout assertion that takes the screen down rather than a
  /// single bad frame. A stream reporting a zero height used to be enough.
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
}
