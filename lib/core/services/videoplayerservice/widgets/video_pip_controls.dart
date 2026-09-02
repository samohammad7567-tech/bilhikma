import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../video_playback.dart';

class VideoPipControls extends StatelessWidget {
  const VideoPipControls({
    required this.playback,
    required this.isVisible,
    required this.onTapUp,
    required this.onClose,
    super.key,
  });

  final VideoPlayback playback;
  final bool isVisible;
  final GestureTapUpCallback onTapUp;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: onTapUp,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedBuilder(
                animation: playback,
                builder: (BuildContext context, _) => Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    playback.isPlaying
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: AnimatedOpacity(
                opacity: isVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
