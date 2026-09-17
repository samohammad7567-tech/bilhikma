/// The language the app is currently rendered in.
///
/// Backend text fields such as a lesson title arrive as
/// `{"ar": "...", "en": "..."}` and are resolved while parsing, where no
/// [BuildContext] exists. This holds the answer for that layer; it is kept in
/// sync with `context.locale` by the root app widget.
class AppLanguage {
  AppLanguage._();

  /// Arabic is the primary language, so it is what a missing translation
  /// falls back to.
  static const String fallbackCode = 'ar';

  static String _code = fallbackCode;

  static String get code => _code;

  static void update(String code) {
    if (code.isEmpty) return;
    _code = code;
  }
}
