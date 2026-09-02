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
  double get aspectRatio => 16 / 9;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {
    _controller.addListener(_onValue);
  }

  void _onValue() {
    final YoutubePlayerValue value = _controller.value;

    _isReady = value.isReady;
    _isPlaying = value.isPlaying;
    _isBuffering = value.playerState == PlayerState.buffering;
    _position = value.position;
    _duration = value.metaData.duration;
    _playbackSpeed = value.playbackRate;
    _errorMessage = value.hasError ? 'YouTube error: ${value.errorCode}' : null;

    notifyListeners();
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

  @override
  Widget buildSurface({Key? key, Widget? overlay}) {
    final Widget player = YoutubePlayer(
      key: key,
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
  }

  @override
  void dispose() {
    _controller.removeListener(_onValue);
    _controller.dispose();
    super.dispose();
  }
}
