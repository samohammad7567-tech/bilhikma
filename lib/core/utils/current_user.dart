import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/cache_keys.dart';
import '../models/auth_user_model.dart';
import 'cache_util.dart';

class CurrentUser {
  CurrentUser._();

  static AuthUserModel? cachedUser() {
    final Map<String, dynamic>? raw = _decode();

    return raw == null ? null : AuthUserModel.fromJson(raw);
  }

  /// The screen-capture exemption the backend last sent, without a request.
  /// Absent cache means no exemption, so captures are reported by default.
  static bool get canCaptureScreen => cachedUser()?.canCaptureScreen ?? false;

  /// Writes a fresh exemption onto the cached user so it survives a restart.
  /// The stored map is patched in place rather than re-encoded from the model,
  /// which keeps every field the backend sent — including any this app version
  /// does not read yet.
  static Future<void> setCaptureExemption(bool canCaptureScreen) async {
    final Map<String, dynamic>? user = _decode();
    if (user == null || user['can_capture_screen'] == canCaptureScreen) return;

    user['can_capture_screen'] = canCaptureScreen;

    await CacheUtil.setString(
      key: CacheKeys.cachedUserKey,
      value: jsonEncode(user),
    );
  }

  static Map<String, dynamic>? _decode() {
    final Object? raw = CacheUtil.get(key: CacheKeys.cachedUserKey);
    if (raw is! String || raw.isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return Map<String, dynamic>.from(decoded);
    } catch (error) {
      debugPrint('Cached user unreadable: $error');
      return null;
    }
  }
}
