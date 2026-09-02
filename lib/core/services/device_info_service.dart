import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Reads the hardware identity of the current device once and caches it.
///
/// Self-contained on purpose: it only depends on `device_info_plus`, so the
/// file can be dropped into any app as-is.
class DeviceInfoService {
  DeviceInfoService._();

  static const String unknown = 'unknown';

  static String _model = unknown;
  static String _manufacturer = unknown;
  static String _osVersion = unknown;
  static bool _isPhysicalDevice = true;
  static bool _initialized = false;

  /// Marketing / hardware model, e.g. `SM-G991B` or `iPhone14,3`.
  static String get model => _model;

  /// Vendor behind the model, e.g. `samsung` or `Apple`.
  static String get manufacturer => _manufacturer;

  /// Operating system version, e.g. `14` or `17.5.1`.
  static String get osVersion => _osVersion;

  /// `false` on emulators and simulators.
  static bool get isPhysicalDevice => _isPhysicalDevice;

  static bool get isInitialized => _initialized;

  /// Manufacturer and model together, e.g. `samsung SM-G991B`.
  static String get fullModel {
    if (_manufacturer == unknown || _model == unknown) return _model;
    if (_model.toLowerCase().startsWith(_manufacturer.toLowerCase())) {
      return _model;
    }
    return '$_manufacturer $_model';
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    try {
      await _read(DeviceInfoPlugin());
    } catch (error) {
      // A missing platform implementation must never block startup: the app
      // keeps running and simply reports `unknown` to the backend.
      debugPrint('DeviceInfoService failed to read the device info: $error');
    }

    _initialized = true;
  }

  static Future<void> _read(DeviceInfoPlugin plugin) async {
    if (kIsWeb) {
      final WebBrowserInfo info = await plugin.webBrowserInfo;
      _model = _orUnknown(info.browserName.name);
      _manufacturer = _orUnknown(info.vendor);
      _osVersion = _orUnknown(info.appVersion);
      _isPhysicalDevice = false;
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final AndroidDeviceInfo info = await plugin.androidInfo;
        _model = _orUnknown(info.model);
        _manufacturer = _orUnknown(info.manufacturer);
        _osVersion = _orUnknown(info.version.release);
        _isPhysicalDevice = info.isPhysicalDevice;
      case TargetPlatform.iOS:
        final IosDeviceInfo info = await plugin.iosInfo;
        _model = _orUnknown(info.utsname.machine);
        _manufacturer = 'Apple';
        _osVersion = _orUnknown(info.systemVersion);
        _isPhysicalDevice = info.isPhysicalDevice;
      case TargetPlatform.macOS:
        final MacOsDeviceInfo info = await plugin.macOsInfo;
        _model = _orUnknown(info.model);
        _manufacturer = 'Apple';
        _osVersion = _orUnknown(info.osRelease);
      case TargetPlatform.windows:
        final WindowsDeviceInfo info = await plugin.windowsInfo;
        _model = _orUnknown(info.computerName);
        _manufacturer = 'Microsoft';
        _osVersion = _orUnknown(info.productName);
      case TargetPlatform.linux:
        final LinuxDeviceInfo info = await plugin.linuxInfo;
        _model = _orUnknown(info.prettyName);
        _manufacturer = _orUnknown(info.id);
        _osVersion = _orUnknown(info.versionId);
      case TargetPlatform.fuchsia:
        _model = 'fuchsia';
    }
  }

  static String _orUnknown(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? unknown : trimmed;
  }
}
