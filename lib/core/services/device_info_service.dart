import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static const String unknown = 'unknown';

  /// Android 8.0. Below this the platform has no Picture-in-Picture, the
  /// bundled WebView is usually frozen at a version the modern web has left
  /// behind, and hardware video decoders are the generation that runs out of
  /// `MediaCodec` instances. Features gate on it rather than guessing.
  static const int androidOreo = 26;

  /// A device with less than this much RAM cannot hold the image cache, a
  /// video decoder and the PDF engine at once on the heap Android grants it.
  static const int _lowRamThresholdMb = 2048;

  static String _model = unknown;
  static String _manufacturer = unknown;
  static String _osVersion = unknown;
  static bool _isPhysicalDevice = true;
  static int _androidSdkInt = 0;
  static int _totalRamMb = 0;
  static bool _isLowRamDevice = false;
  static bool _initialized = false;
  static String get model => _model;
  static String get manufacturer => _manufacturer;
  static String get osVersion => _osVersion;
  static bool get isPhysicalDevice => _isPhysicalDevice;

  /// The Android API level, or 0 on another platform / before initialization.
  static int get androidSdkInt => _androidSdkInt;

  /// Total physical RAM in MB, or 0 when the platform does not report it.
  static int get totalRamMb => _totalRamMb;

  /// True when the device needs the app to spend less — smaller caches, no
  /// Picture-in-Picture, capped playback speed.
  ///
  /// Three signals, any one of which is enough: Android's own low-RAM flag
  /// (set by the OEM on Android Go and similar builds), measured RAM under
  /// [_lowRamThresholdMb], or an OS older than [androidOreo].
  static bool get isLowEndDevice {
    if (_isLowRamDevice) return true;
    if (_totalRamMb > 0 && _totalRamMb < _lowRamThresholdMb) return true;

    return _androidSdkInt > 0 && _androidSdkInt < androidOreo;
  }

  /// True only when the platform is known to support Picture-in-Picture.
  /// Unknown counts as unsupported, so a failed probe never triggers a call
  /// the platform would reject.
  static bool get supportsPictureInPicture =>
      defaultTargetPlatform == TargetPlatform.android &&
      _androidSdkInt >= androidOreo;

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
        _androidSdkInt = info.version.sdkInt;
        _totalRamMb = info.physicalRamSize;
        _isLowRamDevice = info.isLowRamDevice;
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
