import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';
import '../refactor/lesson_playback_reporter.dart';
import 'lesson_audio_player.dart';

class LessonAudioStage extends StatefulWidget {
  const LessonAudioStage({
    required this.url,
    required this.isPreparing,
    required this.onPrepare,
    required this.onTick,
    required this.onEnded,
    required this.resumeSeconds,
    required this.seekLimitSeconds,
    required this.correctionSeconds,
    required this.correctionRevision,
    required this.speed,
    required this.onSpeedChanged,
    super.key,
  });

  final String? url;
  final bool isPreparing;
  final VoidCallback onPrepare;

  final void Function(int positionSeconds, int playedSeconds) onTick;
  final ValueChanged<int> onEnded;

  final int resumeSeconds;
  final int seekLimitSeconds;

  final int? correctionSeconds;
  final int correctionRevision;

  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  @override
  State<LessonAudioStage> createState() => _LessonAudioStageState();
}

class _LessonAudioStageState extends State<LessonAudioStage> {
  late final LessonPlaybackReporter _reporter = LessonPlaybackReporter(
    onTick: (int position, int played) => widget.onTick(position, played),
    onEnded: (int duration) => widget.onEnded(duration),
  );

  VideoPlayback? _playback;
  bool _hasAppliedSpeed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_createIfPossible());
  }

  @override
  void didUpdateWidget(LessonAudioStage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _teardown();
      unawaited(_createIfPossible());
      return;
    }

    if (oldWidget.speed != widget.speed) unawaited(_applySpeed());

    final int? correction = widget.correctionSeconds;
    if (correction != null &&
        oldWidget.correctionRevision != widget.correctionRevision) {
      unawaited(_reporter.seekTo(correction));
    }
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }

  Future<void> _createIfPossible() async {
    final String? url = widget.url;
    if (url == null || url.isEmpty) return;

    final VideoItem? item = VideoItem.fromUrl(url, id: 'lesson-audio');
    if (item == null) return;

    final VideoPlayback playback = VideoPlayback.forItem(item);
    _playback = playback;
    _hasAppliedSpeed = false;
    playback.addListener(_onPlaybackChanged);
    _reporter.attach(playback);

    await playback.initialize();
    if (!mounted) return;

    await _applySpeed();
    await _reporter.resumeAt(widget.resumeSeconds);
  }

  Future<void> _applySpeed() async {
    final VideoPlayback? playback = _playback;
    if (playback == null) return;

    _hasAppliedSpeed = playback.isReady;
    await playback.setPlaybackSpeed(widget.speed.rate);
  }

  /// A rate set before the player is ready is dropped by some backends
  /// (YouTube in particular), so it is applied once more on first ready.
  void _onPlaybackChanged() {
    final VideoPlayback? playback = _playback;
    if (_hasAppliedSpeed || playback == null || !playback.isReady) return;

    unawaited(_applySpeed());
  }

  void _teardown() {
    _reporter.detach();
    _playback?.removeListener(_onPlaybackChanged);
    _playback?.dispose();
    _playback = null;
    _hasAppliedSpeed = false;
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayback? playback = _playback;

    if (playback == null) {
      return LessonAudioPlayer(
        position: Duration.zero,
        duration: Duration.zero,
        maxPosition: Duration.zero,
        isPlaying: false,
        isBuffering: widget.isPreparing,
        onToggle: widget.onPrepare,
        speed: widget.speed,
        onSpeedChanged: widget.onSpeedChanged,
      );
    }

    return ListenableBuilder(
      listenable: playback,
      builder: (BuildContext context, _) => LessonAudioPlayer(
        position: playback.position,
        duration: playback.duration,
        maxPosition: Duration(seconds: widget.seekLimitSeconds),
        isPlaying: playback.isPlaying,
        isBuffering: playback.isBuffering,
        onToggle: playback.togglePlayPause,
        onSeek: (Duration target) => _reporter.seekTo(target.inSeconds),
        speed: widget.speed,
        onSpeedChanged: widget.onSpeedChanged,
      ),
    );
  }
}
