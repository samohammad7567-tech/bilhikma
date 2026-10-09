import 'dart:async';

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
  static const Duration _autoHideDelay = Duration(seconds: 3);
  static const Duration _fadeDuration = Duration(milliseconds: 200);

  late final VideoPlayback _playback;

  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _playback = VideoPlayback.forItem(widget.item);
    _playback.addListener(_onPlaybackChanged);
    _playback.initialize();
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _playback.removeListener(_onPlaybackChanged);
    _restoreOrientation();
    _playback.dispose();
    super.dispose();
  }

  bool get _isLoading => !_playback.isReady || _playback.isBuffering;

  bool get _canAutoHide => _playback.isPlaying && !_isLoading;

  void _onPlaybackChanged() {
    if (!mounted) return;

    // Loading / paused / stopped: controls must stay on screen.
    if (!_canAutoHide) {
      _cancelHideTimer();
      if (!_controlsVisible) setState(() => _controlsVisible = true);
      return;
    }

    // Playing: arm the countdown once, never restart it on position ticks.
    if (_controlsVisible && _hideTimer == null) _armHideTimer();
  }

  void _armHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideDelay, () {
      _hideTimer = null;
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);

    if (_canAutoHide) {
      _armHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _toggleControls() {
    if (!_controlsVisible) {
      _showControls();
      return;
    }

    _cancelHideTimer();
    setState(() => _controlsVisible = false);
  }

  void _onPlayPause() {
    unawaited(_playback.togglePlayPause());
    // The playback listener re-arms the countdown once it is playing again.
    _showControls();
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
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleControls,
                    child: const SizedBox.expand(),
                  ),
                ),

                IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: _fadeDuration,
                    child: _Controls(
                      isPlaying: _playback.isPlaying,
                      isLoading: _isLoading,
                      isFullscreen: widget.isFullscreen,
                      onPlayPause: _onPlayPause,
                      onFullscreen: _toggleFullscreen,
                    ),
                  ),
                ),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
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
    required this.isLoading,
    required this.isFullscreen,
    required this.onPlayPause,
    required this.onFullscreen,
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
