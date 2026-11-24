import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/videoplayerservice/video_item.dart';
import '../../../../core/services/videoplayerservice/video_playback.dart';
import '../../../../core/utils/orientation/video_fullscreen_orientation.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/video_stage_sizing.dart';
import 'live_player_surface.dart';

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
  bool _isMobile = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _playback = VideoPlayback.forItem(widget.item);
    _playback.addListener(_onPlaybackChanged);
    _playback.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MyScreenSize.isMobile(context);
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _playback.removeListener(_onPlaybackChanged);
    if (widget.isFullscreen) {
      unawaited(VideoFullscreenOrientation.restore(isMobile: _isMobile));
    }
    _playback.dispose();
    super.dispose();
  }

  bool get _isLoading => !_playback.isReady || _playback.isBuffering;

  bool get _canAutoHide => _playback.isPlaying && !_isLoading;

  void _onPlaybackChanged() {
    if (!mounted) return;
    if (!_canAutoHide) {
      _cancelHideTimer();
      if (!_controlsVisible) setState(() => _controlsVisible = true);
      return;
    }
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
    _showControls();
  }

  Future<void> _toggleFullscreen() async {
    final bool next = !widget.isFullscreen;
    if (next) {
      await VideoFullscreenOrientation.enter();
    } else {
      await VideoFullscreenOrientation.restore(isMobile: _isMobile);
    }
    widget.onFullscreenChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
        height: VideoStageSizing.height(
          context: context,
          constraints: constraints,
          aspectRatio: _playback.aspectRatio,
          isFullscreen: widget.isFullscreen,
        ),
        width: double.infinity,
        child: LivePlayerSurface(
          playback: _playback,
          controlsVisible: _controlsVisible,
          isPlaying: _playback.isPlaying,
          isLoading: _isLoading,
          isFullscreen: widget.isFullscreen,
          fadeDuration: _fadeDuration,
          onToggleControls: _toggleControls,
          onPlayPause: _onPlayPause,
          onFullscreen: _toggleFullscreen,
        ),
      ),
    );
  }
}
