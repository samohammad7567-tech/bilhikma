import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'floating_video_controller.dart';
import 'video_player_options.dart';
import 'widgets/expanded_video_player.dart';
import 'widgets/video_pip_player.dart';

class FloatingVideoOverlay extends StatelessWidget {
  const FloatingVideoOverlay({
    required this.controller,
    super.key,
    this.options = const FloatingVideoOptions(),
  });

  final FloatingVideoController controller;
  final FloatingVideoOptions options;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        if (!controller.hasVideo) return const SizedBox.shrink();

        return Positioned.fill(
          child: controller.isExpanded
              ? ExpandedVideoPlayer(controller: controller, options: options)
              : VideoPipPlayer(controller: controller, options: options),
        );
      },
    );
  }
}
