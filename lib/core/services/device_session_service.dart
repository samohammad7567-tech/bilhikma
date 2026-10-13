import 'package:dio/dio.dart';

import '../../features/gallery/data/data_source/gallery_data_source.dart';
import '../constants/api_endpoints.dart';
import '../utils/app_logger.dart';
import '../utils/cache_util.dart';
import '../utils/current_user.dart';
import 'device_service.dart';
import 'dio_service.dart';
import 'push_notification_service.dart';
import 'screen_capture_policy.dart';
import 'secure_store.dart';
import '../enums/device_session_status_enum.dart';

class DeviceSessionService {
  DeviceSessionService._();

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

  /// Whether a token is stored at all, which is as much as the device can say
  /// about being signed in without asking the API.
  static bool get hasSession {
    final Object? token = CacheUtil.get(key: tokenKey);
    return token is String && token.isNotEmpty;
  }

  static Future<void> bind(String accessToken) async {
    await DeviceService.ensureInitialized();

    await SecureStore.write(_boundDeviceKey, DeviceService.deviceUuid);
    await SecureStore.write(_boundTokenKey, _fingerprint(accessToken));
  }

  static Future<DeviceSessionStatus> validateCachedSession() async {
    final Object? token = CacheUtil.get(key: tokenKey);
    if (token is! String || token.isEmpty) return DeviceSessionStatus.noSession;

    await DeviceService.ensureInitialized();

    final String? boundDevice = await SecureStore.read(_boundDeviceKey);
    final String? boundToken = await SecureStore.read(_boundTokenKey);
    if (boundDevice == null || boundToken == null) {
      AppLogger.info(
        'No local device binding found; re-binding and deferring to the API',
        name: 'device_session',
      );

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
      AppLogger.warning(
        'Remote logout failed, clearing the local session anyway',
        name: 'device_session',
        error: error,
      );
    } finally {
      await clear();
    }
  }

  static Future<void> clear() async {
    CacheUtil.remove(key: tokenKey);
    CacheUtil.remove(key: refreshTokenKey);
    CurrentUser.clear();
    DioService.updateToken('');

    await ScreenCapturePolicy.clear();

    GalleryDataSource.clearCache();

    await SecureStore.delete(_boundDeviceKey);
    await SecureStore.delete(_boundTokenKey);
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
