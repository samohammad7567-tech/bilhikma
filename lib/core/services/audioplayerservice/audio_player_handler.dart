import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';

import 'audio_track.dart';
import 'playback_uri_resolver.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AudioPlayerHandler({PlaybackUriResolver? resolver, this._defaultArtProvider})
    : _resolver = resolver ?? const DefaultPlaybackUriResolver() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item == null) return;
      mediaItem.add(item.copyWith(duration: duration));
    });
  }

  final PlaybackUriResolver _resolver;

  final Future<Uri?> Function()? _defaultArtProvider;

  final AudioPlayer _player = AudioPlayer();

  List<AudioTrack> _playQueue = [];
  int _queueIndex = 0;

  bool _repeatOneEnabled = false;

  bool _shuffleEnabled = false;
  final List<int> _shuffleHistory = [];
  final Random _random = Random();

  Future<void> _playChain = Future.value();

  double _playbackSpeed = 1.0;

  bool get hasNext =>
      _playQueue.length > 1 &&
      (_shuffleEnabled || _queueIndex < _playQueue.length - 1);

  bool get hasPrevious =>
      _playQueue.length > 1 &&
      (_shuffleEnabled ? _shuffleHistory.isNotEmpty : _queueIndex > 0);

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  bool get isPlaying => _player.playing;

  Future<void> playTrack(
    AudioTrack track, {
    List<AudioTrack>? contextQueue,
    int? contextIndex,
  }) {
    if (contextQueue != null &&
        contextQueue.isNotEmpty &&
        contextIndex != null) {
      _playQueue = List<AudioTrack>.from(contextQueue);
      _queueIndex = contextIndex.clamp(0, _playQueue.length - 1);
    } else {
      _playQueue = [track];
      _queueIndex = 0;
    }
    final run = _playChain.then((_) => _loadAndPlay(track));
    _playChain = run.catchError((Object _) {});
    return run;
  }

  Future<void> _loadAndPlay(AudioTrack track) async {
    try {
      await _player.stop();
    } catch (_) {}

    var item = track.toMediaItem();
    if (item.artUri == null && _defaultArtProvider != null) {
      final fallback = await _defaultArtProvider();
      if (fallback != null) item = item.copyWith(artUri: fallback);
    }
    queue.add([item]);

    mediaItem.add(item);

    final uri = await _resolver.resolve(track);

    try {
      await _player.setAudioSource(
        _sourceForResolvedUri(uri, item, useLockCaching: true),
      );
    } catch (_) {
      await _player.setAudioSource(
        _sourceForResolvedUri(uri, item, useLockCaching: false),
      );
    }

    await _player.setLoopMode(_repeatOneEnabled ? LoopMode.one : LoopMode.off);
    await _player.setSpeed(_playbackSpeed);
    unawaited(_player.play().catchError((Object _, StackTrace st) {}));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.25, 2.0);
    await _player.setSpeed(_playbackSpeed);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_playQueue.isEmpty) return;
    if (_playQueue.length == 1) {
      await _player.seek(Duration.zero);
      if (!_player.playing) await _player.play();
      return;
    }

    int nextIndex;
    if (_shuffleEnabled) {
      _shuffleHistory.add(_queueIndex);
      final candidates = [
        for (var i = 0; i < _playQueue.length; i++)
          if (i != _queueIndex) i,
      ];
      nextIndex = candidates[_random.nextInt(candidates.length)];
    } else {
      if (_queueIndex >= _playQueue.length - 1) {
        await _player.seek(Duration.zero);
        if (!_player.playing) await _player.play();
        return;
      }
      nextIndex = _queueIndex + 1;
    }

    _queueIndex = nextIndex;
    final next = _playQueue[_queueIndex];
    _publishPreviewMediaItem(next);
    final run = _playChain.then((_) => _loadAndPlay(next));
    _playChain = run.catchError((Object _) {});
    await run;
  }

  @override
  Future<void> skipToPrevious() async {
    if (_playQueue.isEmpty) return;

    int prevIndex;
    if (_shuffleEnabled && _shuffleHistory.isNotEmpty) {
      prevIndex = _shuffleHistory.removeLast();
    } else if (!_shuffleEnabled && _queueIndex > 0) {
      prevIndex = _queueIndex - 1;
    } else {
      await _player.seek(Duration.zero);
      if (!_player.playing) await _player.play();
      return;
    }

    _queueIndex = prevIndex;
    final prev = _playQueue[_queueIndex];
    _publishPreviewMediaItem(prev);
    final run = _playChain.then((_) => _loadAndPlay(prev));
    _playChain = run.catchError((Object _) {});
    await run;
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_playQueue.isEmpty || index < 0 || index >= _playQueue.length) return;
    _queueIndex = index;
    final item = _playQueue[_queueIndex];
    _publishPreviewMediaItem(item);
    final run = _playChain.then((_) => _loadAndPlay(item));
    _playChain = run.catchError((Object _) {});
    await run;
  }

  void _publishPreviewMediaItem(AudioTrack track) {
    final item = track.toMediaItem();
    queue.add([item]);
    mediaItem.add(item);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _shuffleEnabled = shuffleMode == AudioServiceShuffleMode.all;
    if (!_shuffleEnabled) _shuffleHistory.clear();
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _repeatOneEnabled = false;
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _repeatOneEnabled = true;
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        _repeatOneEnabled = false;
        await _player.setLoopMode(LoopMode.all);
        break;
      default:
        _repeatOneEnabled = false;
        await _player.setLoopMode(LoopMode.off);
    }
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    if (queue.value.isEmpty) return;
    if (queue.value.length == 1 && queue.value.first.id == mediaItem.id) {
      queue.add([]);
      this.mediaItem.add(null);
      _playQueue = [];
      _queueIndex = 0;
      await _player.stop();
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await playTrack(AudioTrack.fromMediaItem(mediaItem));
  }

  Future<void> dispose() => _player.dispose();

  AudioSource _sourceForResolvedUri(
    Uri uri,
    MediaItem tag, {
    required bool useLockCaching,
  }) {
    if (!useLockCaching || kIsWeb) {
      return AudioSource.uri(uri, tag: tag);
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      return LockCachingAudioSource(uri, tag: tag);
    }
    return AudioSource.uri(uri, tag: tag);
  }

  void _broadcastState(PlaybackEvent event) {
    final processingState = _player.processingState;

    final playing =
        _player.playing && processingState != ProcessingState.completed;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }
}
