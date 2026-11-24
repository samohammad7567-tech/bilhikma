import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';
import 'lesson_playback_reporter.dart';

class LessonPlaybackController {
  LessonPlaybackController({required this.reporter, required this.onChanged});

  final LessonPlaybackReporter reporter;
  final VoidCallback onChanged;

  VideoPlayback? playback;
  double speed = 1;

  bool _hasAppliedSpeed = false;

  Future<void> create({
    required String? url,
    required int resumeSeconds,
    required bool mounted,
  }) async {
    if (url == null || url.isEmpty) return;

    final VideoItem? item = VideoItem.fromUrl(url, id: 'lesson-video');
    if (item == null) return;

    final VideoPlayback next = VideoPlayback.forItem(item);
    playback = next;
    _hasAppliedSpeed = false;
    next.addListener(_onPlaybackChanged);
    reporter.attach(next);

    await next.initialize();
    if (!mounted) return;

    await applySpeed();
    await reporter.beginReportingAt(resumeSeconds);
  }

  Future<void> applySpeed() async {
    final VideoPlayback? current = playback;
    if (current == null) return;

    _hasAppliedSpeed = current.isReady;
    await current.setPlaybackSpeed(speed);
  }

  Future<void> seekCorrection(int seconds) => reporter.seekTo(seconds);

  Future<void> retry({
    required String? url,
    required int resumeSeconds,
    required bool mounted,
  }) async {
    disposePlayback();
    onChanged();
    await create(url: url, resumeSeconds: resumeSeconds, mounted: mounted);
    onChanged();
  }

  void disposePlayback() {
    reporter.detach();
    playback?.removeListener(_onPlaybackChanged);
    playback?.dispose();
    playback = null;
    _hasAppliedSpeed = false;
  }

  void _onPlaybackChanged() {
    final VideoPlayback? current = playback;
    if (_hasAppliedSpeed || current == null || !current.isReady) return;
    unawaited(applySpeed());
  }
}
