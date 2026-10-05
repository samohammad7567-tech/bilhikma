import 'dart:async';

import 'package:flutter/foundation.dart';

/// Owns the auto-hide lifecycle of a media control overlay.
///
/// The value is `true` while the controls should be on screen. Controls hide
/// only while the media is actually playing: a paused or idle player keeps them
/// visible so the user always has a way back in.
class MediaControlsVisibility extends ValueNotifier<bool> {
  MediaControlsVisibility({this.delay = const Duration(seconds: 3)})
    : super(true);

  final Duration delay;

  Timer? _hideTimer;
  bool _canHide = false;

  bool get isVisible => value;

  /// Mirrors the playback state. Starting playback begins the countdown,
  /// pausing cancels it and pins the controls open.
  void setPlaying(bool isPlaying) {
    if (_canHide == isPlaying) return;

    _canHide = isPlaying;
    if (isPlaying) {
      poke();
    } else {
      show();
    }
  }

  /// Any user interaction: reveal the controls and restart the countdown.
  void poke() {
    value = true;
    _restartTimer();
  }

  /// Reveals the controls without arming the countdown.
  void show() {
    _hideTimer?.cancel();
    value = true;
  }

  /// Tap on the video surface: hide immediately when visible, reveal otherwise.
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
