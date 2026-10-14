import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../routing/app_routes.dart';
import '../utils/app_logger.dart';
import '../widgets/app_toast.dart';
import 'device_session_service.dart';

/// The one place the app drops a session it can no longer use and sends the
/// student straight back to the login screen.
///
/// A suspended account, a refused token refresh and a session claimed by
/// another device all end here, so the clearing and the navigation are written
/// once instead of in every interceptor.
class SessionGuard {
  SessionGuard._();

  static const String _logName = 'session_guard';

  static bool _isSigningOut = false;

  /// Clears the stored session and replaces the whole stack with the login
  /// screen. [noticeKey] is a localization key shown as a toast once login is
  /// on screen, so the student is told why they were signed out.
  ///
  /// The notice is only shown when this call is the one that dropped the
  /// session. A request already in flight can be refused long after the
  /// student signed out themselves, and explaining an expiry on the login
  /// screen they are already looking at reads as a failure. The clearing and
  /// the navigation still run either way: something else may have dropped the
  /// session while a protected screen was up — the screen-capture suspension
  /// ends its session in the cubit before the dialog it shows gets here — and
  /// that screen must not be left standing.
  static Future<void> forceSignOut({String? noticeKey}) async {
    if (_isSigningOut) return;
    _isSigningOut = true;

    try {
      final bool hadSession = DeviceSessionService.hasSession;

      await DeviceSessionService.clear();

      final NavigatorState? navigator =
          getIt<GlobalKey<NavigatorState>>().currentState;
      if (navigator == null) {
        AppLogger.warning(
          'Session cleared with no navigator attached; '
          'the login screen will be reached on the next launch',
          name: _logName,
        );
        return;
      }

      navigator.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (Route<dynamic> route) => false,
      );

      if (noticeKey != null && hadSession) _showNotice(navigator, noticeKey);
    } finally {
      _isSigningOut = false;
    }
  }

  static void _showNotice(NavigatorState navigator, String noticeKey) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!navigator.mounted) return;

      AppToast.error(navigator.context, noticeKey.tr());
    });
  }
}
