import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/capped_seek_bar.dart';

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
  bool _showRewindHint = false;

  void _rewind() {
    widget.onRewind();

    setState(() => _showRewindHint = true);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showRewindHint = false);
    });
  }

  void _refuseSkip() {
    AppToast.show(context, 'video_no_skip_note'.tr());
  }

  static String _clock(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _rewind,
                child: _RewindHint(visible: _showRewindHint),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _refuseSkip,
              ),
            ),
          ],
        ),

        if (widget.isBuffering)
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else
          Center(
            child: _RoundButton(
              icon: widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 34.sp,
              onTap: widget.onToggle,
            ),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(12.w, 2.h, 4.w, 2.h),
            color: Colors.black.withValues(alpha: 0.35),
            child: Row(
              children: <Widget>[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${_clock(widget.position)} / ${_clock(widget.duration)}',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ),

                SizedBox(width: 6.w),

                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: CappedSeekBar(
                      position: widget.position,
                      duration: widget.duration,
                      maxPosition: widget.maxPosition,
                      onSeek: widget.onSeek,
                      onBlocked: _refuseSkip,
                    ),
                  ),
                ),

                _RoundButton(
                  icon: widget.isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  size: 20.sp,
                  onTap: widget.onFullscreen,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RewindHint extends StatelessWidget {
  const _RewindHint({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: visible ? 0.25 : 0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 30.sp),
              Text(
                '10s',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
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
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
