import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';

class LivePlayerStage extends StatefulWidget {
  const LivePlayerStage({
    required this.item,
    required this.isFullscreen,
    required this.onFullscreenChanged,
    super.key,
  });

  final VideoItem item;
  final bool isFullscreen;
  final ValueChanged<bool> onFullscreenChanged;

  @override
  State<LivePlayerStage> createState() => _LivePlayerStageState();
}

class _LivePlayerStageState extends State<LivePlayerStage> {
  late final VideoPlayback _playback;

  @override
  void initState() {
    super.initState();
    _playback = VideoPlayback.forItem(widget.item);
    _playback.initialize();
  }

  @override
  void dispose() {
    _restoreOrientation();
    _playback.dispose();
    super.dispose();
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _toggleFullscreen() async {
    final bool next = !widget.isFullscreen;

    if (next) {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _restoreOrientation();
    }

    widget.onFullscreenChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    final double height = widget.isFullscreen
        ? screen.height
        : screen.width / _playback.aspectRatio;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: Colors.black,

        child: _playback.buildSurface(
          overlay: ListenableBuilder(
            listenable: _playback,
            builder: (BuildContext context, _) => Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _Controls(
                  isPlaying: _playback.isPlaying,
                  isBuffering: _playback.isBuffering,
                  isFullscreen: widget.isFullscreen,
                  onPlayPause: _playback.togglePlayPause,
                  onFullscreen: _toggleFullscreen,
                ),

                PositionedDirectional(
                  top: 10.h,
                  start: 10.w,
                  child: const _LiveBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.isPlaying,
    required this.isBuffering,
    required this.isFullscreen,
    required this.onPlayPause,
    required this.onFullscreen,
  });

  final bool isPlaying;
  final bool isBuffering;
  final bool isFullscreen;
  final VoidCallback onPlayPause;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: isBuffering
              ? const CircularProgressIndicator(color: Colors.white)
              : _RoundButton(
                  icon: isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 34.sp,
                  onTap: onPlayPause,
                ),
        ),

        PositionedDirectional(
          bottom: 10.h,
          end: 10.w,
          child: _RoundButton(
            icon: isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            size: 22.sp,
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
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 6.w),

          Text(
            'live_now'.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onError,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
