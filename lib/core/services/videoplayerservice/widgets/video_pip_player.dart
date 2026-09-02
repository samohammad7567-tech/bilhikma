import 'dart:async';
import 'package:flutter/material.dart';
import '../floating_video_controller.dart';
import '../video_playback.dart';
import '../video_player_options.dart';
import 'video_pip_controls.dart';

class VideoPipPlayer extends StatefulWidget {
  const VideoPipPlayer({
    required this.controller,
    required this.options,
    super.key,
  });

  final FloatingVideoController controller;
  final FloatingVideoOptions options;

  @override
  State<VideoPipPlayer> createState() => _VideoPipPlayerState();
}

class _VideoPipPlayerState extends State<VideoPipPlayer> {
  static const double _margin = 12;
  static const double _minWidth = 110;
  static const double _aspect = 150 / 86;

  Size? _gestureStartSize;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHideControls();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _onTapUp(TapUpDetails details, Size size) {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
      _scheduleHideControls();
      return;
    }

    final Offset center = Offset(size.width / 2, size.height / 2);

    if ((details.localPosition - center).distance <= 22) {
      unawaited(widget.controller.playback!.togglePlayPause());
    } else {
      widget.controller.expand();
    }

    _scheduleHideControls();
  }

  @override
  Widget build(BuildContext context) {
    final FloatingVideoController videoController = widget.controller;
    final VideoPlayback playback = videoController.playback!;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final Size size = videoController.pipSize;

        final double maxX = (constraints.maxWidth - size.width - _margin)
            .clamp(_margin, double.infinity)
            .toDouble();

        final double maxY = (constraints.maxHeight - size.height - _margin)
            .clamp(_margin, double.infinity)
            .toDouble();

        final Offset raw = videoController.pipOffset ?? Offset(_margin, maxY);

        final double dx = raw.dx.clamp(_margin, maxX).toDouble();
        final double dy = raw.dy.clamp(_margin, maxY).toDouble();

        return Stack(
          children: <Widget>[
            Positioned(
              left: dx,
              top: dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (_) => _gestureStartSize = size,
                onScaleEnd: (_) => _gestureStartSize = null,
                onScaleUpdate: (ScaleUpdateDetails details) {
                  final Size? startSize = _gestureStartSize;

                  if (details.pointerCount >= 2 && startSize != null) {
                    final double newWidth = (startSize.width * details.scale)
                        .clamp(_minWidth, maxWidth)
                        .toDouble();

                    videoController.updatePipSize(
                      Size(newWidth, newWidth / _aspect),
                    );
                  }

                  if (details.focalPointDelta != Offset.zero) {
                    videoController.updatePipOffset(
                      Offset(dx, dy) + details.focalPointDelta,
                    );
                  }
                },
                child: Container(
                  width: size.width,
                  height: size.height,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: playback.buildSurface(
                    key: videoController.playerKey,
                    overlay: VideoPipControls(
                      playback: playback,
                      isVisible: _controlsVisible,
                      onTapUp: (TapUpDetails details) =>
                          _onTapUp(details, size),
                      onClose: videoController.closeVideo,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
