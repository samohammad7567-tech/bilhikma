import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../video_playback.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
                  padding: EdgeInsets.all((10).r(context)),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    playback.isPlaying
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: (22).r(context),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: (6).h(context),
            right: (6).w(context),
            child: IgnorePointer(
              ignoring: !isVisible,
              child: AnimatedOpacity(
                opacity: isVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: EdgeInsets.all((5).r(context)),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: (16).r(context),
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
