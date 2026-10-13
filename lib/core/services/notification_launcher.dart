import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../routing/app_routes.dart';
import '../routing/notification_destination.dart';

class NotificationLauncher {
  NotificationLauncher._();

  static final NotificationLauncher instance = NotificationLauncher._();

  NotificationDestination? _pending;
  bool _isReady = false;
  void open(NotificationDestination? destination) {
    if (destination != null) {
      _handle(destination);
      return;
    }

    if (_isReady) return;

    _pending = const NotificationDestination(AppRoutes.notification);
  }

  void markReady() {
    _isReady = true;

    final NotificationDestination? pending = _pending;
    if (pending == null) return;

    _pending = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _push(pending));
  }

  void markSignedOut() {
    _isReady = false;
    _pending = null;
  }

  void _handle(NotificationDestination destination) {
    if (!_isReady) {
      _pending = destination;
      return;
    }

    _push(destination);
  }

  void _push(NotificationDestination destination) {
    final NavigatorState? navigator = _navigator;
    if (navigator == null) {
      _pending = destination;
      return;
    }

    navigator.pushNamed(destination.route, arguments: destination.arguments);
  }

  NavigatorState? get _navigator =>
      getIt.isRegistered<GlobalKey<NavigatorState>>()
      ? getIt<GlobalKey<NavigatorState>>().currentState
      : null;
}
