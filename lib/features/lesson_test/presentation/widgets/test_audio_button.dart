import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/services/audioplayerservice/audioplayerservice.dart';

class TestAudioButton extends StatefulWidget {
  const TestAudioButton({required this.url, super.key, this.dense = false});

  final String url;
  final bool dense;

  @override
  State<TestAudioButton> createState() => _TestAudioButtonState();
}

class _TestAudioButtonState extends State<TestAudioButton> {
  late final AudioPlayerHandler _handler = getIt<AudioPlayerHandler>();

  StreamSubscription<PlaybackState>? _subscription;
  bool _isPlaying = false;

  bool get _isCurrentTrack => _handler.mediaItem.value?.id == widget.url;

  @override
  void initState() {
    super.initState();
    _subscription = _handler.playbackState.listen(_syncState);
  }

  @override
  void didUpdateWidget(TestAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;

    if (oldWidget.url == _handler.mediaItem.value?.id) {
      unawaited(_handler.stop());
    }
    _isPlaying = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isCurrentTrack && _handler.isPlaying) {
      unawaited(_handler.stop());
    }
    super.dispose();
  }

  void _syncState(PlaybackState state) {
    final bool playing =
        _isCurrentTrack &&
        state.playing &&
        state.processingState != AudioProcessingState.completed;
    if (playing == _isPlaying || !mounted) return;

    setState(() => _isPlaying = playing);
  }

  Future<void> _toggle() async {
    try {
      if (_isPlaying) {
        await _handler.pause();
        return;
      }

      if (_isCurrentTrack) {
        if (_handler.playbackState.value.processingState ==
            AudioProcessingState.completed) {
          await _handler.seek(Duration.zero);
        }
        await _handler.play();
        return;
      }

      await _handler.playTrack(
        AudioTrack(
          id: widget.url,
          title: widget.url,
          artist: '',
          source: widget.url,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget icon = Icon(
      _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
    );
    final String tooltip =
        (_isPlaying ? LangKeys.quizStopAudio : LangKeys.quizPlayAudio).tr();

    return IconButton.filledTonal(
      onPressed: _toggle,
      tooltip: tooltip,
      icon: icon,
      iconSize: widget.dense ? 18 : null,
      padding: widget.dense ? EdgeInsets.zero : null,
      constraints: widget.dense
          ? BoxConstraints.tightFor(width: 34, height: 34)
          : null,
      visualDensity: widget.dense ? VisualDensity.compact : null,
    );
  }
}
