import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../floating_video_controller.dart';
import '../video_playback.dart';
import '../video_player_options.dart';
import 'video_circle_icon_button.dart';
import 'video_playback_error.dart';
import 'video_live_badge.dart';
import 'video_seek_icon.dart';
import 'video_speed_badge.dart';
import 'video_speed_sheet.dart';
import 'video_progress_bar.dart';

class VideoControlsOverlay extends StatefulWidget {
  const VideoControlsOverlay({
    required this.controller,
    required this.options,
    super.key,
  });

  final FloatingVideoController controller;
  final FloatingVideoOptions options;

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  VideoPlayback get _playback => widget.controller.playback!;

  bool _controlsVisible = true;
  bool _isFastForward = false;
  bool _isLandscape = false;

  int _seekDirection = 0;

  Timer? _hideTimer;
  Timer? _seekFeedbackTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHideControls();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _seekFeedbackTimer?.cancel();

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  void _toggleRotate() {
    final bool goingLandscape = !_isLandscape;
    setState(() => _isLandscape = goingLandscape);

    SystemChrome.setPreferredOrientations(
      goingLandscape
          ? <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControlsVisible() {
    setState(() => _controlsVisible = !_controlsVisible);

    if (_controlsVisible) {
      _scheduleHideControls();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    unawaited(_playback.togglePlayPause());

    setState(() => _controlsVisible = true);
    _scheduleHideControls();
  }

  void _seek(int seconds) {
    if (!_playback.canSeek) return;

    unawaited(_playback.seekBy(Duration(seconds: seconds)));

    setState(() {
      _seekDirection = seconds > 0 ? 1 : -1;
      _controlsVisible = true;
    });

    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _seekDirection = 0);
    });

    _scheduleHideControls();
  }

  void _setFastForward(bool enabled) {
    if (_isFastForward == enabled || !_playback.canSeek) return;

    unawaited(_playback.setPlaybackSpeed(enabled ? 2.0 : 1.0));
    setState(() => _isFastForward = enabled);
  }

  void _onSwipeDownToMinimize(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) > 200) widget.controller.minimize();
  }

  void _showSpeedPicker() {
    VideoSpeedSheet.show(
      context: context,
      options: widget.options,
      currentSpeed: _playback.playbackSpeed,
      onSpeedSelected: (double speed) =>
          unawaited(_playback.setPlaybackSpeed(speed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _playback,
      builder: (BuildContext context, _) {
        final String? error = _playback.errorMessage;
        if (error != null) {
          return VideoPlaybackError(
            message: error,
            options: widget.options,
            onRetry: widget.controller.retry,
            onClose: widget.controller.closeVideo,
          );
        }

        return Stack(fit: StackFit.expand, children: _layers());
      },
    );
  }

  List<Widget> _layers() {
    final bool isLoading = !_playback.isReady || _playback.isBuffering;

    return <Widget>[
      Row(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControlsVisible,
              onDoubleTap: () => _seek(-10),
              onVerticalDragEnd: _onSwipeDownToMinimize,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _seekDirection == -1 ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const VideoSeekIcon(
                    icon: CupertinoIcons.gobackward_10,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControlsVisible,
              onDoubleTap: () => _seek(10),
              onLongPressStart: (_) => _setFastForward(true),
              onLongPressEnd: (_) => _setFastForward(false),
              onVerticalDragEnd: _onSwipeDownToMinimize,
              child: Center(
                child: _isFastForward
                    ? VideoSpeedBadge(color: widget.options.accentColor)
                    : AnimatedOpacity(
                        opacity: _seekDirection == 1 ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const VideoSeekIcon(
                          icon: CupertinoIcons.goforward_10,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),

      if (isLoading)
        Center(
          child: CircularProgressIndicator(color: widget.options.accentColor),
        )
      else if (_controlsVisible)
        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _playback.isPlaying
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),

      if (_controlsVisible) ...<Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    VideoCircleIconButton(
                      icon: _isLandscape
                          ? CupertinoIcons.fullscreen_exit
                          : CupertinoIcons.fullscreen,
                      onTap: _toggleRotate,
                    ),

                    const SizedBox(width: 10),

                    VideoCircleIconButton(
                      icon: CupertinoIcons.slider_horizontal_3,
                      onTap: _showSpeedPicker,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: _playback.isLive
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: VideoLiveBadge(label: widget.options.liveLabel),
                )
              : VideoProgressBar(
                  playback: _playback,
                  accentColor: widget.options.accentColor,
                ),
        ),
      ],
    ];
  }
}
