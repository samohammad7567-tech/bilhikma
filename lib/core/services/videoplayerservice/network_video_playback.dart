import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

import 'video_playback.dart';

class NetworkVideoPlayback extends VideoPlayback {
  NetworkVideoPlayback(super.item);

  vp.VideoPlayerController? _controller;
  String? _errorMessage;
  bool _isDisposed = false;

  vp.VideoPlayerValue get _value =>
      _controller?.value ?? const vp.VideoPlayerValue.uninitialized();

  @override
  bool get isReady => _value.isInitialized;

  @override
  bool get isPlaying => _value.isPlaying;

  @override
  bool get isBuffering => _value.isBuffering;

  @override
  bool get isLive =>
      item.isLive || (isReady && _value.duration <= Duration.zero);

  @override
  Duration get position => _value.position;

  @override
  Duration get duration => _value.duration;

  @override
  double get playbackSpeed => _value.playbackSpeed;

  @override
  double get aspectRatio => isReady ? _value.aspectRatio : 16 / 9;

  @override
  String? get errorMessage => _errorMessage ?? _value.errorDescription;

  @override
  Future<void> initialize() async {
    final Uri? uri = item.mediaUri;
    if (uri == null) {
      _errorMessage = 'Invalid video URL: ${item.source}';
      notifyListeners();
      return;
    }

    final vp.VideoPlayerController controller =
        vp.VideoPlayerController.networkUrl(uri, httpHeaders: item.httpHeaders);
    _controller = controller;
    controller.addListener(_onValueChanged);

    try {
      await controller.initialize();
      if (_isDisposed) return;
      await controller.play();
    } catch (error) {
      _errorMessage = '$error';
    }

    if (!_isDisposed) notifyListeners();
  }

  void _onValueChanged() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> seekTo(Duration target) async => _controller?.seekTo(target);

  @override
  Future<void> setPlaybackSpeed(double speed) async =>
      _controller?.setPlaybackSpeed(speed);

  @override
  Widget buildSurface({Key? key, Widget? overlay}) {
    final vp.VideoPlayerController? controller = _controller;

    return Stack(
      key: key,
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(
          color: Colors.black,
          child: controller == null || !controller.value.isInitialized
              ? const SizedBox.expand()
              : Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: vp.VideoPlayer(controller),
                  ),
                ),
        ),

        if (overlay != null) Positioned.fill(child: overlay),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.removeListener(_onValueChanged);
    unawaited(_controller?.dispose());
    _controller = null;
    super.dispose();
  }
}
