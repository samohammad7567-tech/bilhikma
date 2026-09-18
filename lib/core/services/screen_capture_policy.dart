import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/data/repos/profile_repo.dart';
import '../../features/security/data/models/security_event_model.dart';
import '../utils/cache_util.dart';
import '../utils/current_user.dart';
import 'device_session_service.dart';
import 'screen_capture_service.dart';

class ScreenCapturePolicy {
  ScreenCapturePolicy._();

  static const ProfileRepo _profile = ProfileRepo();

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

  static Future<void> clear() => resolve(canCaptureScreen: false);

  static bool get _hasSession {
    final Object? token = CacheUtil.get(key: DeviceSessionService.tokenKey);
    return token is String && token.isNotEmpty;
  }
}
