import 'package:flutter/material.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LivePlayerControls extends StatelessWidget {
  const LivePlayerControls({
    required this.isPlaying,
    required this.isLoading,
    required this.isFullscreen,
    required this.onPlayPause,
    required this.onFullscreen,
    super.key,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isFullscreen;
  final VoidCallback onPlayPause;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (!isLoading)
          Center(
            child: _RoundButton(
              icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: (34).r(context),
              onTap: onPlayPause,
            ),
          ),
        PositionedDirectional(
          bottom: (10).h(context),
          end: (10).h(context),
          child: _RoundButton(
            icon: isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            size: (22).r(context),
            onTap: onFullscreen,
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all((10).r(context)),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
