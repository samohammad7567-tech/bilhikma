import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'app_info_service.dart';
import 'device_info_service.dart';

class DeviceService {
  DeviceService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _key = 'device_uuid';

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

  static Future<String> _readOrCreate() async {
    final String? existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;

    final String id = const Uuid().v4();
    await _storage.write(key: _key, value: id);
    return id;
  }
}
