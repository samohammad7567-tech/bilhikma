import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the running build's identity once and caches it.
///
/// Self-contained on purpose: it only depends on `package_info_plus`, so the
/// file can be dropped into any app as-is.
class AppInfoService {
  AppInfoService._();

  static const String unknown = 'unknown';

  static String _appName = unknown;
  static String _packageName = unknown;
  static String _version = unknown;
  static String _buildNumber = unknown;
  static bool _initialized = false;

  /// Human readable app name, e.g. `Bilhikma`.
  static String get appName => _appName;

  /// Bundle id / application id, e.g. `com.bilhikma.app`.
  static String get packageName => _packageName;

  /// Semantic version only, e.g. `1.0.0`.
  static String get version => _version;

  /// Build number only, e.g. `2`.
  static String get buildNumber => _buildNumber;

  /// Version and build together, e.g. `1.0.0+2`.
  static String get fullVersion => _version == unknown
      ? unknown
      : '$_version+$_buildNumber';

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
      // A missing platform implementation must never block startup: the app
      // keeps running and simply reports `unknown` to the backend.
      debugPrint('AppInfoService failed to read the package info: $error');
    }

    _initialized = true;
  }

  static String _orUnknown(String value) => value.trim().isEmpty
      ? unknown
      : value.trim();
}
