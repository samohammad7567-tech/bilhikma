import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';

/// The app's only door to the platform keychain / Android Keystore.
///
/// `FlutterSecureStorage` is backed by the Android Keystore, which is the least
/// reliable storage on the platform. On older and OEM-patched builds (Android
/// 7-9, and several Huawei / Xiaomi / Samsung images) a read can fail outright
/// after an OS update, a backup restore or a user-triggered credential reset:
///
/// ```text
/// javax.crypto.BadPaddingException: pad block corrupted
/// java.security.UnrecoverableKeyException: Failed to obtain information about key
/// android.security.KeyStoreException: the master key ... exists but is unusable
/// ```
///
/// Those are normal conditions in the field, not programming errors, so every
/// method here is total: it answers with a value or with `null`/`false`, and
/// never throws into the caller. Secure storage is a convenience for the app,
/// never a precondition for it starting.
class SecureStore {
  SecureStore._();

  static const String _logName = 'secure_store';

  /// Keystore work is local cryptography — milliseconds in practice, even on
  /// old hardware — so this is already generous. It is here only to stop a
  /// wedged platform channel from blocking a caller forever, which on the
  /// startup path used to mean a frozen splash screen.
  ///
  /// Keep it well under the startup step budget in `AppBootstrap`: a failing
  /// read spends this twice (the read, then the cleanup delete), and the step
  /// wrapping it has to be able to outlast that.
  static const Duration _timeout = Duration(seconds: 5);

  /// `resetOnError` lets the plugin throw away a master key it can no longer
  /// use and mint a fresh one, which turns the common corruption case into a
  /// single lost value instead of a permanently broken install. It is the
  /// plugin default; it is spelled out because the app depends on it.
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static bool _isAvailable = true;

  /// False once the keystore has failed in a way it did not recover from.
  ///
  /// Callers do not need to check this — every method already honours it — but
  /// it is worth reading before offering a feature that cannot work without
  /// durable secrets.
  static bool get isAvailable => _isAvailable;

  /// Returns the stored value, or `null` if there is none *or* the keystore
  /// could not be read. A caller that must distinguish "absent" from
  /// "unreadable" should consult [isAvailable] afterwards.
  static Future<String?> read(String key) async {
    if (!_isAvailable) return null;

    try {
      return await _storage.read(key: key).timeout(_timeout);
    } catch (error, stackTrace) {
      _onFailure('read "$key"', error, stackTrace);

      // A value that cannot be decrypted will not become readable on the next
      // attempt either. Dropping it clears the way for a fresh write instead
      // of failing identically on every launch.
      await delete(key);
      return null;
    }
  }

  /// Returns true when the value is safely stored.
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

  /// Best-effort removal. A delete that fails is logged and ignored: there is
  /// nothing useful a caller can do about it.
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

    // A timeout means the channel itself is unresponsive, so every later call
    // would cost another full timeout. Stop paying it for the rest of the
    // session; a plain crypto failure is per-value and leaves the store usable.
    if (error is TimeoutException) {
      _isAvailable = false;
      AppLogger.error(
        'Secure storage marked unavailable for this session',
        name: _logName,
      );
    }
  }
}
