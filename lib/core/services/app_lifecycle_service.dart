import 'dart:async';

import 'package:flutter/material.dart';

import 'screen_capture_policy.dart';

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._();

  static final AppLifecycleService instance = AppLifecycleService._();

  AppLifecycleState? _currentState;

  final StreamController<void> _resumed = StreamController<void>.broadcast();

  AppLifecycleState? get currentState => _currentState;

  /// Emits every time the app comes back to the foreground, so cubits can
  /// refresh data that may have changed while the app was away.
  Stream<void> get onResumed => _resumed.stream;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _currentState = WidgetsBinding.instance.lifecycleState;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final AppLifecycleState? previous = _currentState;
    _currentState = state;

    if (state != AppLifecycleState.resumed || previous == state) return;

    unawaited(ScreenCapturePolicy.refresh());

    if (!_resumed.isClosed) _resumed.add(null);
  }
}
