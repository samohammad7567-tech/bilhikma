import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../routing/app_routes.dart';
import '../routing/notification_destination.dart';

/// Opens the screen a tapped notification refers to.
///
/// A tap can land before the app has anywhere to navigate — a push that cold
/// starts the app, for instance — so a destination that cannot be shown yet is
/// held until [markReady] reports signed-in UI is up.
class NotificationLauncher {
  NotificationLauncher._();

  static final NotificationLauncher instance = NotificationLauncher._();

  NotificationDestination? _pending;
  bool _isReady = false;

  /// Opens [destination].
  ///
  /// A tap with nothing specific to open lands on the notifications list when
  /// it started the app, so the tap is never a dead end; while the app is
  /// already running it simply comes forward where the user left off.
  void open(NotificationDestination? destination) {
    if (destination != null) {
      _handle(destination);
      return;
    }

    if (_isReady) return;

    _pending = const NotificationDestination(AppRoutes.notification);
  }

  /// Signed-in UI is on screen: replay whatever a tap asked for earlier.
  void markReady() {
    _isReady = true;

    final NotificationDestination? pending = _pending;
    if (pending == null) return;

    _pending = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _push(pending));
  }

  /// Back on the sign-in screen: nothing held may be opened any more.
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
