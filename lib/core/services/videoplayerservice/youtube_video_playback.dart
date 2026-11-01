import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_playback.dart';

class YoutubeVideoPlayback extends VideoPlayback {
  YoutubeVideoPlayback(super.item)
    : _controller = YoutubePlayerController(
        initialVideoId: item.source,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,

          hideControls: true,
          hideThumbnail: true,
          controlsVisibleAtStart: false,
        ),
      );

  final YoutubePlayerController _controller;

  bool _isReady = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isDisposed = false;
  Size? _surfaceSize;
  Timer? _resizeTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1;
  String? _errorMessage;

  @override
  bool get isReady => _isReady;

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isBuffering => _isBuffering;

  @override
  bool get isLive => item.isLive || (_isReady && _duration == Duration.zero);

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  double get reportedAspectRatio => VideoPlayback.fallbackAspectRatio;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {
    _controller.addListener(_onValue);
  }

  void _onValue() {
    if (_isDisposed) return;

    final YoutubePlayerValue value = _controller.value;
    final bool becameReady = !_isReady && value.isReady;

    _isReady = value.isReady;
    _isPlaying = value.isPlaying;
    _isBuffering = value.playerState == PlayerState.buffering;
    _position = value.position;
    _duration = value.metaData.duration;
    _playbackSpeed = value.playbackRate;
    _errorMessage = value.hasError ? 'YouTube error: ${value.errorCode}' : null;

    if (becameReady) _applySurfaceSize();

    notifyListeners();
  }

  /// The YouTube surface lives in an iframe inside a platform WebView. Flutter
  /// resizes the WebView, but the embedded iframe keeps the pixel size it was
  /// created with unless it is told to resize — which is why the video stayed
  /// small/letterboxed while the player itself went full screen. Measuring the
  /// surface and forwarding the size through `setSize` keeps the iframe in step
  /// with inline ⇄ fullscreen and portrait ⇄ landscape changes.
  void _rememberSurfaceSize(Size size) {
    if (!size.width.isFinite || !size.height.isFinite) return;
    if (size.width <= 0 || size.height <= 0) return;
    if (size == _surfaceSize) return;

    _surfaceSize = size;

    if (_isReady) _applySurfaceSize();
  }

  void _applySurfaceSize() {
    if (_isDisposed || !_isReady || _surfaceSize == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) => _sendSurfaceSize());

    // The platform WebView can report its new size a few frames after the
    // Flutter layout changes (especially right after a rotation), so repeat the
    // resize once the viewport has settled.
    _resizeTimer?.cancel();
    _resizeTimer = Timer(const Duration(milliseconds: 350), _sendSurfaceSize);
  }

  void _sendSurfaceSize() {
    final Size? size = _surfaceSize;

    if (_isDisposed || !_isReady || size == null) return;

    _controller.setSize(size);
  }

  @override
  Future<void> play() async => _controller.play();

  @override
  Future<void> pause() async => _controller.pause();

  @override
  Future<void> seekTo(Duration target) async =>
      _controller.seekTo(target, allowSeekAhead: true);

  @override
  Future<void> setPlaybackSpeed(double speed) async =>
      _controller.setPlaybackRate(speed);

  Future<void> toggleFullScreen() async {
    _controller.toggleFullScreenMode();
  }

  @override
  Widget buildSurface({Key? key, Widget? overlay}) {
    return LayoutBuilder(
      key: key,
      builder: (BuildContext context, BoxConstraints constraints) {
        _rememberSurfaceSize(constraints.biggest);

        final Widget player = YoutubePlayer(
          controller: _controller,
          aspectRatio: aspectRatio,
          showVideoProgressIndicator: false,
          bottomActions: const <Widget>[],
          topActions: const <Widget>[],
        );

        if (overlay == null) return player;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            player,
            Positioned.fill(child: overlay),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _resizeTimer?.cancel();
    _controller.removeListener(_onValue);
    _controller.dispose();
    super.dispose();
  }
}
