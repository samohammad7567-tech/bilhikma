import 'package:flutter/material.dart';

import '../../../../core/services/videoplayerservice/video_playback.dart';
import 'live_player_badge.dart';
import 'live_player_controls.dart';

class LivePlayerSurface extends StatelessWidget {
  const LivePlayerSurface({
    required this.playback,
    required this.controlsVisible,
    required this.isPlaying,
    required this.isLoading,
    required this.isFullscreen,
    required this.fadeDuration,
    required this.onToggleControls,
    required this.onPlayPause,
    required this.onFullscreen,
    super.key,
  });

  final VideoPlayback playback;
  final bool controlsVisible;
  final bool isPlaying;
  final bool isLoading;
  final bool isFullscreen;
  final Duration fadeDuration;
  final VoidCallback onToggleControls;
  final VoidCallback onPlayPause;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: playback.buildSurface(
        overlay: ListenableBuilder(
          listenable: playback,
          builder: (BuildContext context, _) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleControls,
                  child: const SizedBox.expand(),
                ),
              ),
              IgnorePointer(
                ignoring: !controlsVisible,
                child: AnimatedOpacity(
                  opacity: controlsVisible ? 1 : 0,
                  duration: fadeDuration,
                  child: LivePlayerControls(
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    isFullscreen: isFullscreen,
                    onPlayPause: onPlayPause,
                    onFullscreen: onFullscreen,
                  ),
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              PositionedDirectional(
                top: 10,
                start: 10,
                child: const LivePlayerBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
