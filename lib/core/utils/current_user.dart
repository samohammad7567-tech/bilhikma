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

  static bool get canCaptureScreen => cachedUser()?.canCaptureScreen ?? false;
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
