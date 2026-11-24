import 'package:flutter/material.dart';

import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';
import 'lesson_video_controls.dart';
import 'lesson_video_error.dart';
import 'lesson_video_placeholder.dart';

class LessonVideoSurface extends StatelessWidget {
  const LessonVideoSurface({
    required this.playback,
    required this.isPreparing,
    required this.onPrepare,
    required this.onRetry,
    required this.seekLimitSeconds,
    required this.onSeek,
    required this.isFullscreen,
    required this.onFullscreen,
    required this.speed,
    required this.onSpeedChanged,
    required this.isLessonCompleted,
    super.key,
  });

  final VideoPlayback? playback;
  final bool isPreparing;
  final VoidCallback onPrepare;
  final VoidCallback onRetry;
  final int seekLimitSeconds;
  final ValueChanged<Duration> onSeek;
  final bool isFullscreen;
  final VoidCallback onFullscreen;
  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;
  final bool isLessonCompleted;

  @override
  Widget build(BuildContext context) {
    final VideoPlayback? current = playback;

    return ColoredBox(
      color: Colors.black,
      child: current == null
          ? LessonVideoPlaceholder(isPreparing: isPreparing, onTap: onPrepare)
          : ListenableBuilder(
              listenable: current,
              builder: (BuildContext context, _) {
                final String? failure = current.errorMessage;
                if (failure != null) {
                  return LessonVideoError(details: failure, onRetry: onRetry);
                }

                return current.buildSurface(
                  overlay: LessonVideoControls(
                    isPlaying: current.isPlaying,
                    isBuffering: current.isBuffering,
                    isFullscreen: isFullscreen,
                    position: current.position,
                    duration: current.duration,
                    maxPosition: Duration(seconds: seekLimitSeconds),
                    onToggle: current.togglePlayPause,
                    onRewind: () =>
                        current.seekBy(const Duration(seconds: -10)),
                    onSeek: onSeek,
                    onFullscreen: onFullscreen,
                    speed: speed,
                    onSpeedChanged: onSpeedChanged,
                    isLessonCompleted: isLessonCompleted,
                  ),
                );
              },
            ),
    );
  }
}
