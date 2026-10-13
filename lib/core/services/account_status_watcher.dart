import 'dart:async';

import '../../features/profile/data/repos/profile_repo.dart';
import '../utils/app_logger.dart';
import 'account_suspension_service.dart';
import 'device_session_service.dart';
import 'push_event_bus.dart';
import 'session_guard.dart';

/// Keeps the app honest about the account it is signed in with while it sits
/// open.
///
/// Suspending a student is a dashboard action, so nothing on the device knows
/// about it until the platform says so. Two things tell the app: the
/// `account_status` push the platform sends, and the 403 the suspended token
/// starts answering with — the first is read here, the second in the auth
/// interceptor. Either way the student lands on the login screen.
class AccountStatusWatcher {
  AccountStatusWatcher._();

  static const String _logName = 'account_status';

  static const ProfileRepo _profile = ProfileRepo();

  static StreamSubscription<Map<String, dynamic>>? _pushes;

  static bool _isVerifying = false;

  static void initialize() {
    _pushes ??= PushEventBus.instance.stream.listen(_onPush);
  }

  static void _onPush(Map<String, dynamic> data) {
    if (!DeviceSessionService.hasSession) return;

    if (AccountSuspensionService.isSuspensionPush(data)) {
      AppLogger.info(
        'Push announced a suspension; signing out',
        name: _logName,
      );

      unawaited(
        SessionGuard.forceSignOut(
          noticeKey: AccountSuspensionService.errorKey,
        ),
      );
      return;
    }

    if (!AccountSuspensionService.isAccountStatusPush(data)) return;

    unawaited(verifyNow());
  }

  /// Asks the API for the account as it stands now. A suspended token is
  /// refused with 403, which the auth interceptor turns into a forced sign-out,
  /// so there is nothing to do with the answer here beyond not crashing on it.
  static Future<void> verifyNow() async {
    if (_isVerifying || !DeviceSessionService.hasSession) return;
    _isVerifying = true;

    try {
      await _profile.fetchProfile();
    } catch (error) {
      AppLogger.warning(
        'Account state could not be re-read',
        name: _logName,
        error: error,
      );
    } finally {
      _isVerifying = false;
    }
  }
}
