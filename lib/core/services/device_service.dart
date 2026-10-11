import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../constants/cache_keys.dart';
import '../utils/app_logger.dart';
import '../utils/cache_util.dart';
import 'app_info_service.dart';
import 'device_info_service.dart';
import 'secure_store.dart';

class DeviceService {
  DeviceService._();

  static const String _key = CacheKeys.deviceUuidKey;

  static const String deviceUuidHeader = 'X-Device-Uuid';
  static const String platformHeader = 'X-Platform';
  static const String appVersionHeader = 'X-App-Version';
  static const String appBuildHeader = 'X-App-Build';
  static const String deviceModelHeader = 'X-Device-Model';

  static const String deviceUuidField = 'device_uuid';
  static const String platformField = 'platform';
  static const String deviceModelField = 'device_model';
  static const String appVersionField = 'app_version';
  static const String appBuildField = 'app_build';

  static String? _cachedId;

  static Future<String> ensureInitialized() async {
    await Future.wait(<Future<void>>[
      DeviceInfoService.ensureInitialized(),
      AppInfoService.ensureInitialized(),
    ]);

    return _cachedId ??= await _readOrCreate();
  }

  static String get deviceUuid => _cachedId ?? '';

  static bool get isInitialized => _cachedId != null;

  static String get platform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    TargetPlatform() => defaultTargetPlatform.name.toLowerCase(),
  };
  static String get deviceModel => DeviceInfoService.model;
  static String get appVersion => AppInfoService.version;
  static String get appBuild => AppInfoService.buildNumber;

  static Map<String, String> get headers => <String, String>{
    deviceUuidHeader: deviceUuid,
    platformHeader: platform,
    appVersionHeader: appVersion,
    appBuildHeader: appBuild,
    deviceModelHeader: deviceModel,
  };
  static Map<String, dynamic> get metadata => <String, dynamic>{
    deviceUuidField: deviceUuid,
    platformField: platform,
    deviceModelField: deviceModel,
    appVersionField: appVersion,
    appBuildField: appBuild,
  };

  /// Resolves this install's device id, in order of trust, and never throws.
  ///
  /// The id identifies the install to the backend, which binds the session to
  /// it, so losing it signs the user out. The keychain is the primary home,
  /// but on older Android it loses values after an OS update or a credential
  /// reset — so a plain mirror in shared preferences is both written and read
  /// back. The id is an opaque install identifier, not a secret, so the mirror
  /// costs nothing in confidentiality and buys back the session.
  static Future<String> _readOrCreate() async {
    final String? secure = await SecureStore.read(_key);
    if (secure != null && secure.isNotEmpty) {
      _mirror(secure);
      return secure;
    }

    final Object? mirrored = CacheUtil.get(key: _key);
    if (mirrored is String && mirrored.isNotEmpty) {
      AppLogger.warning(
        'Device id recovered from the preferences mirror; '
        'restoring it to secure storage',
        name: 'device_service',
      );

      // Put it back, so the keychain is authoritative again next launch.
      await SecureStore.write(_key, mirrored);
      return mirrored;
    }

    final String id = const Uuid().v4();
    final bool stored = await SecureStore.write(_key, id);
    _mirror(id);

    if (!stored) {
      AppLogger.warning(
        'Device id could not be written to secure storage; '
        'the preferences mirror is holding it',
        name: 'device_service',
      );
    }

    return id;
  }

  static void _mirror(String id) {
    if (CacheUtil.get(key: _key) == id) return;

    // Fire-and-forget: the value is already in hand, and a failed mirror write
    // must not delay or fail initialization.
    CacheUtil.setString(key: _key, value: id).ignore();
  }
}
