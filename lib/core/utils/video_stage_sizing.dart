import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'my_screen_size.dart';

class VideoStageSizing {
  VideoStageSizing._();

  static const double maxHeightRatio = 0.55;

  static double height({
    required BuildContext context,
    required BoxConstraints constraints,
    required double aspectRatio,
    required bool isFullscreen,
  }) {
    final double viewportHeight = MyScreenSize.heightFraction(context, 1);
    final double maxHeight = constraints.maxHeight.isFinite
        ? math.min(constraints.maxHeight, viewportHeight)
        : viewportHeight;
    if (isFullscreen) return maxHeight;

    if (MyScreenSize.isLandscape(context) &&
        MyScreenSize.isCompactHeight(context)) {
      return maxHeight;
    }

    final double width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : MyScreenSize.width(context);
    final double heightCap = math.min(
      maxHeight,
      MyScreenSize.heightFraction(context, maxHeightRatio),
    );
    return math.min(width / aspectRatio, heightCap);
  }
}
