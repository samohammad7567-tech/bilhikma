import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  AppInfoService._();

  static const String unknown = 'unknown';

  static String _appName = unknown;
  static String _packageName = unknown;
  static String _version = unknown;
  static String _buildNumber = unknown;
  static bool _initialized = false;
  static String get appName => _appName;
  static String get packageName => _packageName;
  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get fullVersion =>
      _version == unknown ? unknown : '$_version+$_buildNumber';

  static bool get isInitialized => _initialized;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    try {
      final PackageInfo info = await PackageInfo.fromPlatform();

      _appName = _orUnknown(info.appName);
      _packageName = _orUnknown(info.packageName);
      _version = _orUnknown(info.version);
      _buildNumber = _orUnknown(info.buildNumber);
    } catch (error) {
      debugPrint('AppInfoService failed to read the package info: $error');
    }

    _initialized = true;
  }

  static String _orUnknown(String value) =>
      value.trim().isEmpty ? unknown : value.trim();
}
