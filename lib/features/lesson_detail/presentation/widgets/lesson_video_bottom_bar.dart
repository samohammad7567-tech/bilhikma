import 'package:flutter/material.dart';

import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/widgets/capped_seek_bar.dart';
import '../../../../core/widgets/playback_speed_button.dart';
import 'lesson_video_round_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonVideoBottomBar extends StatelessWidget {
  const LessonVideoBottomBar({
    required this.isFullscreen,
    required this.position,
    required this.duration,
    required this.maxPosition,
    required this.onSeek,
    required this.onBlocked,
    required this.onInteraction,
    required this.onFullscreen,
    required this.speed,
    required this.onPickSpeed,
    super.key,
  });

  final bool isFullscreen;
  final Duration position;
  final Duration duration;
  final Duration maxPosition;

  final ValueChanged<Duration> onSeek;
  final VoidCallback onBlocked;
  final VoidCallback onInteraction;
  final VoidCallback onFullscreen;

  final PlaybackSpeed speed;
  final VoidCallback onPickSpeed;

  static String _clock(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB((12).w(context), (2).h(context), (4).w(context), (2).h(context)),
      color: Colors.black.withValues(alpha: 0.35),
      child: Row(
        children: <Widget>[
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${_clock(position)} / ${_clock(duration)}',
              style: TextStyle(color: Colors.white, fontSize: (11).sp(context)),
            ),
          ),

          SizedBox(width: (6).w(context)),

          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: CappedSeekBar(
                position: position,
                duration: duration,
                maxPosition: maxPosition,
                onSeek: onSeek,
                onBlocked: onBlocked,
                onInteraction: onInteraction,
              ),
            ),
          ),

          PlaybackSpeedButton(
            speed: speed,
            onTap: onPickSpeed,
            onOverlay: true,
          ),

          SizedBox(width: (4).w(context)),

          LessonVideoRoundButton(
            icon: isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            size: (20).r(context),
            onTap: onFullscreen,
          ),
        ],
      ),
    );
  }
}
