import 'dart:async';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/security/data/models/security_event_model.dart';
import '../utils/current_user.dart';
import 'account_status_watcher.dart';
import 'device_session_service.dart';
import 'screen_capture_service.dart';

class ScreenCapturePolicy {
  ScreenCapturePolicy._();

  static bool _isExempt = false;

  static StreamSubscription<SecurityEventResponseModel>? _reports;

  static bool get isExempt => _isExempt;
  static void initialize() {
    _reports ??= ScreenCaptureService.instance.reports.listen(_onReport);
  }

  static Future<void> _onReport(SecurityEventResponseModel response) async {
    final bool? canCaptureScreen = response.canCaptureScreen;
    if (canCaptureScreen == null || canCaptureScreen == _isExempt) return;

    await resolve(canCaptureScreen: canCaptureScreen);
  }

  static Future<void> resolve({required bool canCaptureScreen}) async {
    _isExempt = canCaptureScreen;

    if (_hasSession) await CurrentUser.setCaptureExemption(canCaptureScreen);

    ScreenCaptureService.instance.applyExemption(canCaptureScreen);
  }

  static Future<void> restore() async {
    if (!_hasSession) return clear();

    await resolve(canCaptureScreen: CurrentUser.canCaptureScreen);
  }

  /// Re-reads the exemption from the API, which is also what catches an
  /// account the platform has moved out of the active state: the read goes
  /// through the watcher, which signs the student out rather than handing back
  /// a profile. An unreadable answer keeps the exemption already in force.
  static Future<void> refresh() async {
    if (!_hasSession) return clear();

    final ProfileModel? profile = await AccountStatusWatcher.readProfile();

    await resolve(
      canCaptureScreen:
          profile?.canCaptureScreen ?? CurrentUser.canCaptureScreen,
    );
  }

  static Future<void> clear() => resolve(canCaptureScreen: false);

  static bool get _hasSession => DeviceSessionService.hasSession;
}
