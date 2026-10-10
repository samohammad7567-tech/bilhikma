import 'dart:async';

import '../../../../core/services/videoplayerservice/video_playback.dart';

class LessonPlaybackReporter {
  LessonPlaybackReporter({required this.onTick, required this.onEnded});

  static const Duration _tick = Duration(seconds: 1);

  static const Duration _endWindow = Duration(milliseconds: 400);
  static const Duration _durationTimeout = Duration(seconds: 10);
  static const Duration _durationPoll = Duration(milliseconds: 250);

  final void Function(int positionSeconds, int playedSeconds) onTick;
  final void Function(int durationSeconds) onEnded;

  VideoPlayback? _playback;
  Timer? _ticker;
  int _lastPositionSeconds = -1;
  bool _hasEnded = false;

  /// Binds to [playback] without reporting anything yet.
  ///
  /// Ticks stay off until [beginReportingAt] has placed the player, otherwise
  /// the first tick fires while the media is still loading at second zero and
  /// reports that as the user's position — overwriting the very spot the
  /// lesson was about to resume from.
  void attach(VideoPlayback playback) {
    detach();

    _playback = playback;
    _hasEnded = false;
    _lastPositionSeconds = -1;

    playback.addListener(_watchForEnd);
  }

  void detach() {
    _ticker?.cancel();
    _ticker = null;

    _playback?.removeListener(_watchForEnd);
    _playback = null;
  }

  /// Seeks to [seconds] and starts reporting playback from there.
  ///
  /// Always starts the ticker, even when there is nothing to seek to, so a
  /// lesson opened at the beginning is still tracked.
  Future<void> beginReportingAt(int seconds) async {
    await _seekForResume(seconds);

    final VideoPlayback? playback = _playback;
    if (playback == null) return;

    _lastPositionSeconds = playback.position.inSeconds;
    _ticker ??= Timer.periodic(_tick, (_) => _reportTick());
  }

  Future<void> _seekForResume(int seconds) async {
    final VideoPlayback? playback = _playback;
    if (playback == null || seconds <= 0) return;

    final Duration duration = await _awaitDuration(playback);
    if (duration <= Duration.zero) return;
    if (!identical(_playback, playback)) return;

    // Clamped a second short of the end: seeking to the very last frame makes
    // some backends report the media as ended and snap back to zero, which
    // would replay a lesson the user had all but finished.
    final int last = duration.inSeconds - 1;

    await playback.seekTo(Duration(seconds: seconds > last ? last : seconds));
  }

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
