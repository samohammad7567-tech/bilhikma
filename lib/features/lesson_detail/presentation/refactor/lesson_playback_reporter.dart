import 'dart:async';

import '../../../../core/services/videoplayerservice/video_playback.dart';

class LessonPlaybackReporter {
  LessonPlaybackReporter({required this.onTick, required this.onEnded});

  static const Duration _tick = Duration(seconds: 1);

  static const Duration _endWindow = Duration(milliseconds: 400);

  /// How long a resume waits for the media to report its duration.
  static const Duration _durationTimeout = Duration(seconds: 10);
  static const Duration _durationPoll = Duration(milliseconds: 250);

  final void Function(int positionSeconds, int playedSeconds) onTick;
  final void Function(int durationSeconds) onEnded;

  VideoPlayback? _playback;
  Timer? _ticker;
  int _lastPositionSeconds = -1;
  bool _hasEnded = false;

  void attach(VideoPlayback playback) {
    detach();

    _playback = playback;
    _hasEnded = false;
    _lastPositionSeconds = -1;

    playback.addListener(_watchForEnd);
    _ticker = Timer.periodic(_tick, (_) => _reportTick());
  }

  void detach() {
    _ticker?.cancel();
    _ticker = null;

    _playback?.removeListener(_watchForEnd);
    _playback = null;
  }

  Future<void> resumeAt(int seconds) async {
    final VideoPlayback? playback = _playback;
    if (playback == null || seconds <= 0) return;

    final Duration duration = await _awaitDuration(playback);
    if (duration <= Duration.zero || seconds >= duration.inSeconds) return;
    if (!identical(_playback, playback)) return;

    await playback.seekTo(Duration(seconds: seconds));
  }

  /// A file player knows its duration as soon as it finishes initializing, but
  /// YouTube only reports one once its metadata arrives — reading it straight
  /// away would drop the resume seek on every YouTube lesson.
  Future<Duration> _awaitDuration(VideoPlayback playback) async {
    final DateTime deadline = DateTime.now().add(_durationTimeout);

    while (playback.duration <= Duration.zero) {
      if (!identical(_playback, playback)) return Duration.zero;
      if (!DateTime.now().isBefore(deadline)) break;

      await Future<void>.delayed(_durationPoll);
    }

    return playback.duration;
  }

  Future<void> seekTo(int seconds) async {
    final VideoPlayback? playback = _playback;
    if (playback == null) return;

    _hasEnded = false;

    await playback.seekTo(Duration(seconds: seconds < 0 ? 0 : seconds));
  }

  void _reportTick() {
    final VideoPlayback? playback = _playback;
    if (playback == null) return;

    final int seconds = playback.position.inSeconds;
    final bool isPlaying = playback.isPlaying;

    if (!isPlaying && seconds == _lastPositionSeconds) return;

    // The server validates watched_delta_seconds against wall-clock time and
    // caps anything above it, so a second only counts when the media actually
    // moved — a buffering stall must not inflate the counter.
    final bool hasPlayedASecond = isPlaying && !playback.isBuffering;

    _lastPositionSeconds = seconds;

    onTick(seconds, hasPlayedASecond ? 1 : 0);
  }

  void _watchForEnd() {
    final VideoPlayback? playback = _playback;
    if (playback == null || _hasEnded) return;

    final Duration duration = playback.duration;
    if (duration <= Duration.zero) return;
    if (playback.position < duration - _endWindow) return;

    _hasEnded = true;

    onEnded(duration.inSeconds);
  }
}
