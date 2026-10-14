import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../routing/app_routes.dart';
import '../utils/app_logger.dart';
import '../utils/error_mapper.dart';
import '../widgets/app_toast.dart';
import 'device_session_service.dart';

/// The one place the app drops a session it can no longer use and sends the
/// student straight back to the login screen.
///
/// Every refusal the session cannot survive ends here — an account the
/// platform has shut out, a refused token refresh, a session claimed by
/// another device — so the clearing and the navigation are written once
/// instead of in every interceptor.
///
/// Which refusals those are is not decided here: it is read off the code the
/// API answered with, in [ErrorMapper].
class SessionGuard {
  SessionGuard._();

  static const String _logName = 'session_guard';

  static bool _isSigningOut = false;

  /// Ends the session when the code a request was refused with says it is
  /// over, and does nothing otherwise.
  ///
  /// Every refusal in the app passes through here, so the decision is read off
  /// [ErrorMapper] in one place instead of each caller judging a status code
  /// for itself. A failure arriving with no session left — a login being
  /// refused, or a request that lost a race with a sign-out already done — is
  /// nothing to act on: there is no session to end and no student to send
  /// anywhere.
  static Future<void> endIfRefused(AppException error) async {
    if (!error.endsSession) return;
    if (!DeviceSessionService.hasSession) return;

    AppLogger.info(
      'The API refused a request with ${error.statusCode}; '
      'the session is over',
      name: _logName,
    );

    await forceSignOut(noticeKey: ErrorMapper.sessionEndedKey);
  }

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
