import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/localization/lang_keys.dart';

class TestAudioButton extends StatefulWidget {
  const TestAudioButton({required this.url, super.key});

  final String url;

  @override
  State<TestAudioButton> createState() => _TestAudioButtonState();
}

class _TestAudioButtonState extends State<TestAudioButton> {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _subscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _subscription = _player.playerStateStream.listen(_onPlayerState);
  }

  @override
  void didUpdateWidget(TestAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;

    unawaited(_player.stop());
    _isPlaying = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_player.dispose());
    super.dispose();
  }

  void _onPlayerState(PlayerState state) {
    final bool playing =
        state.playing && state.processingState != ProcessingState.completed;
    if (playing == _isPlaying || !mounted) return;

    setState(() => _isPlaying = playing);
  }

  Future<void> _toggle() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      if (_player.duration == null) {
        await _player.setUrl(widget.url);
      }

      await _player.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: _toggle,
      tooltip: (_isPlaying ? LangKeys.quizStopAudio : LangKeys.quizPlayAudio)
          .tr(),
      icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
    );
  }
}
