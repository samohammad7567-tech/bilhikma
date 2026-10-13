import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static const String _defaultName = 'bilhikma';

  static void info(String message, {String name = _defaultName}) {
    developer.log(message, name: name);
  }

  static void warning(
    String message, {
    String name = _defaultName,
    Object? error,
  }) {
    developer.log('WARNING $message', name: name, error: error);
  }

  static void error(
    String message, {
    String name = _defaultName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
