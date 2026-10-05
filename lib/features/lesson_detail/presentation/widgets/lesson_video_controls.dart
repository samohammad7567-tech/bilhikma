import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/media_controls_visibility.dart';
import '../../../../core/widgets/app_toast.dart';
import 'lesson_video_bottom_bar.dart';
import 'lesson_video_round_button.dart';
import 'lesson_video_tap_layer.dart';

class LessonVideoControls extends StatefulWidget {
  const LessonVideoControls({
    required this.isPlaying,
    required this.isBuffering,
    required this.isFullscreen,
    required this.position,
    required this.duration,
    required this.maxPosition,
    required this.onToggle,
    required this.onRewind,
    required this.onSeek,
    required this.onFullscreen,
    super.key,
  });

  final bool isPlaying;
  final bool isBuffering;
  final bool isFullscreen;
  final Duration position;
  final Duration duration;

  final Duration maxPosition;

  final VoidCallback onToggle;
  final VoidCallback onRewind;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onFullscreen;

  @override
  State<LessonVideoControls> createState() => _LessonVideoControlsState();
}

class _LessonVideoControlsState extends State<LessonVideoControls> {
  final MediaControlsVisibility _visibility = MediaControlsVisibility();

  @override
  void initState() {
    super.initState();
    _visibility.setPlaying(widget.isPlaying);
  }

  @override
  void didUpdateWidget(LessonVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      _visibility.setPlaying(widget.isPlaying);
    }
  }

  @override
  void dispose() {
    _visibility.dispose();
    super.dispose();
  }

  void _run(VoidCallback action) {
    action();
    _visibility.poke();
  }

  void _refuseSkip() {
    _visibility.poke();
    AppToast.show(context, 'video_no_skip_note'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        LessonVideoTapLayer(
          onTap: _visibility.toggle,
          onRewind: () => _run(widget.onRewind),
          onRefuseSkip: _refuseSkip,
        ),

        if (widget.isBuffering)
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        ValueListenableBuilder<bool>(
          valueListenable: _visibility,
          builder: (BuildContext context, bool visible, Widget? child) =>
              IgnorePointer(
                ignoring: !visible,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: child,
                ),
              ),
          child: _controls(),
        ),
      ],
    );
  }

  Widget _controls() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (!widget.isBuffering)
          Center(
            child: LessonVideoRoundButton(
              icon: widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 34.sp,
              onTap: () => _run(widget.onToggle),
            ),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LessonVideoBottomBar(
            isFullscreen: widget.isFullscreen,
            position: widget.position,
            duration: widget.duration,
            maxPosition: widget.maxPosition,
            onSeek: (Duration target) => _run(() => widget.onSeek(target)),
            onBlocked: _refuseSkip,
            onInteraction: _visibility.poke,
            onFullscreen: () => _run(widget.onFullscreen),
          ),
        ),
      ],
    );
  }
}
