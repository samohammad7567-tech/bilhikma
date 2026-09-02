import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../refactor/home_formats.dart';
import '../../../../core/themes/app_theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    super.key,
    this.size,
    this.stroke,
  });
  final double progress;
  final double? size;
  final double? stroke;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double diameter = size ?? 46.w;
    final double thickness = stroke ?? 5.w;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          stroke: thickness,
          track: colors.surfaceContainerHigh,
          fill: colors.secondary,
        ),
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.all(thickness * 1.4),
              child: Text(
                HomeFormats.percent(progress),
                style: AppTheme.styles(context).labelStrong,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.fill,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Color fill;
  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Rect arcRect = bounds.deflate(stroke / 2);

    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, _start, 2 * math.pi, false, base..color = track);

    if (progress <= 0) return;

    canvas.drawArc(
      arcRect,
      _start,
      2 * math.pi * progress,
      false,
      base..color = fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.stroke != stroke ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}
