import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonAudioPlayButton extends StatelessWidget {
  const LessonAudioPlayButton({
    required this.isPlaying,
    required this.onToggle,
    super.key,
    this.isBuffering = false,
  });

  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: SizedBox(
          width: (48).w(context),
          height: (48).h(context),
          child: isBuffering
              ? Padding(
                  padding: EdgeInsets.all((14).r(context)),
                  child: CircularProgressIndicator(
                    strokeWidth: (2).r(context),
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: (26).r(context),
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
