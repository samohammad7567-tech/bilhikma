import 'package:flutter/material.dart';

import 'video_item.dart';

class FloatingVideoOptions {
  const FloatingVideoOptions({
    this.backgroundColor = const Color(0xFF0B3B2E),
    this.accentColor = const Color(0xFF00E4A0),
    this.foregroundColor = Colors.white,
    this.gradientColors,
    this.speedSheetTitle = 'Playback speed',
    this.speedOptions = const <MapEntry<String, double>>[
      MapEntry('0.5x', 0.5),
      MapEntry('0.75x', 0.75),
      MapEntry('Normal', 1),
      MapEntry('1.25x', 1.25),
      MapEntry('1.5x', 1.5),
      MapEntry('2x', 2),
    ],
    this.descriptionLabel = 'Description',
    this.liveLabel = 'LIVE',
    this.retryLabel = 'Retry',
    this.enablePictureInPicture = true,
    this.onShare,
    this.detailsBuilder,
  });

  final Color backgroundColor;
  final Color accentColor;
  final Color foregroundColor;

  final List<Color>? gradientColors;

  final String speedSheetTitle;

  final List<MapEntry<String, double>> speedOptions;

  final String descriptionLabel;

  final String liveLabel;

  final String retryLabel;

  final bool enablePictureInPicture;

  final void Function(VideoItem item)? onShare;

  final Widget Function(BuildContext context, VideoItem item)? detailsBuilder;

  List<Color> resolveGradient() =>
      gradientColors ??
      <Color>[
        backgroundColor,
        Color.lerp(backgroundColor, Colors.black, 0.35) ?? backgroundColor,
      ];
}
