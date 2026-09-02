import 'dart:async';

import 'package:flutter/material.dart';

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

  @override
  State<LessonAudioStage> createState() => _LessonAudioStageState();
}

class _LessonAudioStageState extends State<LessonAudioStage> {
  late final LessonPlaybackReporter _reporter = LessonPlaybackReporter(
    onTick: (int position, int played) => widget.onTick(position, played),
    onEnded: (int duration) => widget.onEnded(duration),
  );

  VideoPlayback? _playback;

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
    _reporter.attach(playback);

    await playback.initialize();
    if (!mounted) return;

    await _reporter.resumeAt(widget.resumeSeconds);
  }

  void _teardown() {
    _reporter.detach();
    _playback?.dispose();
    _playback = null;
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
      ),
    );
  }
}
