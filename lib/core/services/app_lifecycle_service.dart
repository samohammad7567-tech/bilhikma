import 'dart:async';

import 'package:flutter/material.dart';

import 'screen_capture_policy.dart';

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._();

  static final AppLifecycleService instance = AppLifecycleService._();

  AppLifecycleState? _currentState;

  AppLifecycleState? get currentState => _currentState;

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
  }
}
