class AppLanguage {
  AppLanguage._();
  static const String fallbackCode = 'ar';

  static String _code = fallbackCode;

  static String get code => _code;

  static void update(String code) {
    if (code.isEmpty) return;
    _code = code;
  }
}
