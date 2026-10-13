import 'dart:async';

import 'package:flutter/foundation.dart';

class MediaControlsVisibility extends ValueNotifier<bool> {
  MediaControlsVisibility({this.delay = const Duration(seconds: 3)})
    : super(true);

  final Duration delay;

  Timer? _hideTimer;
  bool _canHide = false;

  bool get isVisible => value;
  void setPlaying(bool isPlaying) {
    if (_canHide == isPlaying) return;

    _canHide = isPlaying;
    if (isPlaying) {
      poke();
    } else {
      show();
    }
  }

  void poke() {
    value = true;
    _restartTimer();
  }

  void show() {
    _hideTimer?.cancel();
    value = true;
  }

  void toggle() {
    if (!value) return poke();

    _hideTimer?.cancel();
    value = false;
  }

  void _restartTimer() {
    _hideTimer?.cancel();
    if (!_canHide) return;

    _hideTimer = Timer(delay, () => value = false);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}
