import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          width: 48.w,
          height: 48.w,
          child: isBuffering
              ? Padding(
                  padding: EdgeInsets.all(14.w),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 26.w,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
