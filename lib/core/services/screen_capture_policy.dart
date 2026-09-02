import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/data/repos/profile_repo.dart';
import '../../features/security/data/models/security_event_model.dart';
import '../utils/cache_util.dart';
import '../utils/current_user.dart';
import 'device_session_service.dart';
import 'screen_capture_service.dart';

/// Owns the single answer the rest of the app asks about screen capture:
/// may *this* account capture the screen?
///
/// Nothing here blocks a capture. The window is never protected from Dart —
/// screenshots and recordings are allowed to happen so they can be observed,
/// and an account without permission has every one of them reported to
/// `/user/security-events`. An account with permission is not listened to at
/// all, so nothing of theirs reaches the endpoint.
///
/// `can_capture_screen` arrives with the login response, is repeated by
/// `GET /user/profile`, and comes back again on every security-event response,
/// so the flag is resolved at login, restored from the cached user on a cold
/// start, re-read on resume, and corrected the moment the backend changes it.
class ScreenCapturePolicy {
  ScreenCapturePolicy._();

  static const ProfileRepo _profile = ProfileRepo();

  static bool _isExempt = false;

  static StreamSubscription<SecurityEventResponseModel>? _reports;

  static bool get isExempt => _isExempt;

  /// Every reported event answers with the account's current permission, which
  /// is the earliest the app can learn that it was granted or revoked. Started
  /// once at boot; the cubit listens to the same broadcast stream for warnings
  /// and suspensions.
  static void initialize() {
    _reports ??= ScreenCaptureService.instance.reports.listen(_onReport);
  }

  static Future<void> _onReport(SecurityEventResponseModel response) async {
    final bool? canCaptureScreen = response.canCaptureScreen;
    // Absent from the payload means "unchanged", not "revoked".
    if (canCaptureScreen == null || canCaptureScreen == _isExempt) return;

    await resolve(canCaptureScreen: canCaptureScreen);
  }

  /// Applies what the backend sent and remembers it, so the next cold start
  /// knows the answer before the first response comes back.
  static Future<void> resolve({required bool canCaptureScreen}) async {
    _isExempt = canCaptureScreen;

    if (_hasSession) await CurrentUser.setCaptureExemption(canCaptureScreen);

    ScreenCaptureService.instance.applyExemption(canCaptureScreen);
  }

  /// Cold start, before the first frame: the login response is long gone, so
  /// the flag comes off the user cached at login. No request is made — an
  /// exempt account must not spend the splash reporting its own screenshots
  /// while a profile call is still in flight.
  static Future<void> restore() async {
    if (!_hasSession) return clear();

    await resolve(canCaptureScreen: CurrentUser.canCaptureScreen);
  }

  /// Resume and splash: picks up an exemption granted or revoked since login.
  static Future<void> refresh() async {
    if (!_hasSession) return clear();

    try {
      final ProfileModel profile = await _profile.fetchProfile();

      await resolve(canCaptureScreen: profile.canCaptureScreen);
    } catch (error) {
      debugPrint('Capture exemption unreadable, keeping the last one: $error');

      await resolve(canCaptureScreen: CurrentUser.canCaptureScreen);
    }
  }

  /// No session, or one that just ended: report again. The detectors keep
  /// running, but [ScreenCaptureService.report] drops anything raised without a
  /// token, so nothing is sent until the next sign-in.
  static Future<void> clear() => resolve(canCaptureScreen: false);

  static bool get _hasSession {
    final Object? token = CacheUtil.get(key: DeviceSessionService.tokenKey);
    return token is String && token.isNotEmpty;
  }
}
