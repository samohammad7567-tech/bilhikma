import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static const String unknown = 'unknown';

  static String _model = unknown;
  static String _manufacturer = unknown;
  static String _osVersion = unknown;
  static bool _isPhysicalDevice = true;
  static bool _initialized = false;
  static String get model => _model;
  static String get manufacturer => _manufacturer;
  static String get osVersion => _osVersion;
  static bool get isPhysicalDevice => _isPhysicalDevice;

  static bool get isInitialized => _initialized;
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
