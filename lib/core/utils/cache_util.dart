import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';

class CacheUtil {
  static const String _logName = 'cache';

  static SharedPreferences? _prefs;

  /// False when preferences could not be opened. Every getter then answers
  /// `null` and every setter is a no-op, which looks exactly like a fresh
  /// install — so the app still runs, it just cannot remember anything.
  static bool get isReady => _prefs != null;

  /// Opens the preference store. Safe to call more than once, and never throws:
  /// this runs before the first frame, where an exception would mean the app
  /// never starts at all.
  static Future<void> init() async {
    if (_prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      // A corrupted preferences XML is the usual cause, and it is recoverable:
      // the platform rewrites the file once something asks for it again.
      AppLogger.error(
        'Preferences unavailable — the app will run without stored state',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> setBool({
    required String key,
    required bool value,
  }) async {
    await _prefs?.setBool(key, value);
  }

  static Future<void> setString({
    required String key,
    required String value,
  }) async {
    await _prefs?.setString(key, value);
  }

  static Future<void> setDouble({
    required String key,
    required double value,
  }) async {
    await _prefs?.setDouble(key, value);
  }

  static Future<void> setInt({required String key, required int value}) async {
    await _prefs?.setInt(key, value);
  }

  static Future<void> setStringList({
    required String key,
    required List<String> value,
  }) async {
    await _prefs?.setStringList(key, value);
  }

  static dynamic get({required String key}) {
    return _prefs?.get(key);
  }

  static void remove({required String key}) {
    _prefs?.remove(key);
  }
}
