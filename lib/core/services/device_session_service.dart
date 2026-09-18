import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/gallery/data/data_source/gallery_data_source.dart';
import '../constants/api_endpoints.dart';
import '../utils/cache_util.dart';
import 'device_service.dart';
import 'dio_service.dart';
import 'push_notification_service.dart';
import 'screen_capture_policy.dart';
import '../enums/device_session_status_enum.dart';

class DeviceSessionService {
  DeviceSessionService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';
  static const String _boundDeviceKey = 'session_device_id';
  static const String _boundTokenKey = 'session_token_fingerprint';
  static const Set<String> conflictCodes = <String>{
    'device_conflict',
    'device_mismatch',
    'device_already_linked',
    'device_already_registered',
    'session_active_on_another_device',
    'already_logged_in_on_another_device',
  };
  static Map<String, dynamic> loginPayload() => <String, dynamic>{
    ...DeviceService.metadata,
    if (PushNotificationService.token != null)
      'fcm_token': PushNotificationService.token,
  };

  static Future<void> bind(String accessToken) async {
    await DeviceService.ensureInitialized();

    await _storage.write(key: _boundDeviceKey, value: DeviceService.deviceUuid);
    await _storage.write(key: _boundTokenKey, value: _fingerprint(accessToken));
  }

  static Future<DeviceSessionStatus> validateCachedSession() async {
    final Object? token = CacheUtil.get(key: tokenKey);
    if (token is! String || token.isEmpty) return DeviceSessionStatus.noSession;

    await DeviceService.ensureInitialized();

    String? boundDevice;
    String? boundToken;

    try {
      boundDevice = await _storage.read(key: _boundDeviceKey);
      boundToken = await _storage.read(key: _boundTokenKey);
    } catch (error) {
      debugPrint('Secure storage unreadable, deferring to the API: $error');
    }

    if (boundDevice == null || boundToken == null) {
      await bind(token);
      return DeviceSessionStatus.valid;
    }

    final bool belongsHere =
        boundDevice == DeviceService.deviceUuid &&
        boundToken == _fingerprint(token);

    return belongsHere
        ? DeviceSessionStatus.valid
        : DeviceSessionStatus.deviceMismatch;
  }

  static Future<void> logout() async {
    try {
      await DioService.post(
        ApiEndpoints.logout,
        data: <String, dynamic>{'device_uuid': DeviceService.deviceUuid},
      );
    } catch (error) {
      debugPrint('Remote logout failed, clearing local session anyway: $error');
    } finally {
      await clear();
    }
  }

  static Future<void> clear() async {
    CacheUtil.remove(key: tokenKey);
    CacheUtil.remove(key: refreshTokenKey);
    DioService.updateToken('');

    await ScreenCapturePolicy.clear();

    GalleryDataSource.clearCache();

    await _storage.delete(key: _boundDeviceKey);
    await _storage.delete(key: _boundTokenKey);
  }

  static bool isDeviceConflict(Object error) {
    if (error is! DioException) return false;

    final Response<dynamic>? response = error.response;
    if (response == null) return false;
    if (response.statusCode == 409) return true;

    return _carriesConflictCode(response.data);
  }

  static bool _carriesConflictCode(Object? data) {
    if (data is! Map) return false;

    for (final String field in const <String>['code', 'error', 'error_code']) {
      final Object? value = data[field];
      if (value is String && conflictCodes.contains(value.toLowerCase())) {
        return true;
      }
    }

    return _carriesConflictCode(data['data']);
  }

  static String _fingerprint(String value) {
    int hash = 0x811C9DC5;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
