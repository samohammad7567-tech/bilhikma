import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';

class SecureStore {
  SecureStore._();

  static const String _logName = 'secure_store';
  static const Duration _timeout = Duration(seconds: 5);
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static bool _isAvailable = true;
  static bool get isAvailable => _isAvailable;
  static Future<String?> read(String key) async {
    if (!_isAvailable) return null;

    try {
      return await _storage.read(key: key).timeout(_timeout);
    } catch (error, stackTrace) {
      _onFailure('read "$key"', error, stackTrace);
      await delete(key);
      return null;
    }
  }

  static Future<bool> write(String key, String value) async {
    if (!_isAvailable) return false;

    try {
      await _storage.write(key: key, value: value).timeout(_timeout);
      return true;
    } catch (error, stackTrace) {
      _onFailure('write "$key"', error, stackTrace);
      return false;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key).timeout(_timeout);
    } catch (error) {
      AppLogger.warning(
        'Could not delete "$key" from secure storage',
        name: _logName,
        error: error,
      );
    }
  }

  static void _onFailure(String action, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Secure storage could not $action',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
    if (error is TimeoutException) {
      _isAvailable = false;
      AppLogger.error(
        'Secure storage marked unavailable for this session',
        name: _logName,
      );
    }
  }
}
