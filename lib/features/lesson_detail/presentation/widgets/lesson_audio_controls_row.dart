import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/widgets/playback_speed_button.dart';
import '../../../../core/widgets/playback_speed_sheet.dart';
import 'lesson_audio_play_button.dart';
import 'lesson_audio_skip_button.dart';

/// Transport row of the audio player.
///
/// The rate pill sits at the start of the row; the flexible slot on either
/// side keeps the transport buttons centred whatever the pill's width.
class LessonAudioControlsRow extends StatelessWidget {
  const LessonAudioControlsRow({
    required this.isPlaying,
    required this.isBuffering,
    required this.onToggle,
    required this.speed,
    required this.onSpeedChanged,
    super.key,
    this.onRewind,
    this.onForward,
  });

  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onToggle;

  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  final VoidCallback? onRewind;
  final VoidCallback? onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: PlaybackSpeedButton(
              speed: speed,
              onTap: () => _pickSpeed(context),
            ),
          ),
        ),

        LessonAudioSkipButton(icon: Icons.skip_next, onTap: onRewind),

        SizedBox(width: 22.w),

        LessonAudioPlayButton(
          isPlaying: isPlaying,
          isBuffering: isBuffering,
          onToggle: onToggle,
        ),

        SizedBox(width: 22.w),

        LessonAudioSkipButton(icon: Icons.skip_previous, onTap: onForward),

        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Future<void> _pickSpeed(BuildContext context) => PlaybackSpeedSheet.show(
    context: context,
    current: speed,
    onSelected: onSpeedChanged,
  );
}
