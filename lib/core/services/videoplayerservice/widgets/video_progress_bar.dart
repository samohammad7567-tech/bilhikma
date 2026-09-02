import 'dart:async';
import 'package:flutter/material.dart';
import '../video_playback.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({
    required this.playback,
    required this.accentColor,
    super.key,
  });

  final VideoPlayback playback;
  final Color accentColor;

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  double? _dragFraction;

  void _updateDrag(double dx, double width, Duration duration) {
    if (width <= 0) return;

    final double fraction = (dx / width).clamp(0.0, 1.0).toDouble();
    setState(() => _dragFraction = fraction);

    if (duration > Duration.zero) {
      unawaited(widget.playback.seekTo(duration * fraction));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.playback,
      builder: (BuildContext context, _) {
        final Duration duration = widget.playback.duration;

        final double fraction =
            _dragFraction ??
            (duration.inMilliseconds == 0
                ? 0.0
                : (widget.playback.position.inMilliseconds /
                          duration.inMilliseconds)
                      .clamp(0.0, 1.0)
                      .toDouble());

        return Directionality(
          textDirection: TextDirection.ltr,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails details) =>
                    _updateDrag(details.localPosition.dx, width, duration),
                onHorizontalDragStart: (DragStartDetails details) =>
                    _updateDrag(details.localPosition.dx, width, duration),
                onHorizontalDragUpdate: (DragUpdateDetails details) =>
                    _updateDrag(details.localPosition.dx, width, duration),
                onHorizontalDragEnd: (_) =>
                    setState(() => _dragFraction = null),
                child: SizedBox(
                  height: 24,
                  width: width,
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: <Widget>[
                      Container(
                        width: width,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Container(
                        width: width * fraction,
                        height: 3,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Positioned(
                        left: (width * fraction - 7)
                            .clamp(0.0, width - 14)
                            .toDouble(),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
