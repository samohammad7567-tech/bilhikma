import 'dart:developer' as developer;

/// Single logging entry point for the app.
///
/// Release builds keep these calls rather than compiling them out: a startup
/// failure on a user's phone is precisely the thing that has to leave a trace.
/// They go through `dart:developer`, so they land in logcat under a readable
/// tag instead of stdout, and cost nothing when nobody is attached.
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
