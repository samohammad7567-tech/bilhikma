import 'dart:async';

import '../widgets/lesson_video_stage.dart';
import 'lesson_playback_controller.dart';

class LessonVideoStageSync {
  const LessonVideoStageSync({
    required this.controller,
    required this.applyOrientation,
  });

  final LessonPlaybackController controller;
  final Future<void> Function({required bool fullscreen}) applyOrientation;

  void call({
    required LessonVideoStage oldWidget,
    required LessonVideoStage widget,
    required bool mounted,
  }) {
    if (oldWidget.isFullscreen != widget.isFullscreen) {
      unawaited(applyOrientation(fullscreen: widget.isFullscreen));
    }

    if (oldWidget.speed != widget.speed) {
      controller.speed = widget.speed.rate;
      unawaited(controller.applySpeed());
    }

    if (oldWidget.url != widget.url) {
      controller.disposePlayback();
      unawaited(
        controller.create(
          url: widget.url,
          resumeSeconds: widget.resumeSeconds,
          mounted: mounted,
        ),
      );
      return;
    }

    final int? correction = widget.correctionSeconds;
    if (correction != null &&
        oldWidget.correctionRevision != widget.correctionRevision) {
      unawaited(controller.seekCorrection(correction));
    }
  }
}
