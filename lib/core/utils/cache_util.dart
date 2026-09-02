import 'package:shared_preferences/shared_preferences.dart';

class CacheUtil {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
