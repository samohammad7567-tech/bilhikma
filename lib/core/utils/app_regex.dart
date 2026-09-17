class AppRegex {
  AppRegex._();

  static final RegExp email = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp passwordLetter = RegExp(r'[A-Za-z]');
  static final RegExp passwordNumber = RegExp(r'\d');
  static final RegExp passwordUpper = RegExp('[A-Z]');
  static final RegExp passwordLower = RegExp('[a-z]');
  static final RegExp passwordSymbol = RegExp(r'[^A-Za-z0-9]');

  /// Accepts local and international formats, e.g. `0958953288`,
  /// `+963958953288`, `00963958953288`. The value is sent to the backend
  /// exactly as the user typed it, so no normalization happens here.
  static final RegExp phone = RegExp(r'^(?:\+|00)?\d{7,15}$');

  /// Characters allowed while typing a phone number: digits and a leading `+`.
  static final RegExp phoneAllowedChars = RegExp(r'[\d+]');

  static bool isValidPhone(String value) => phone.hasMatch(value.trim());

  static bool isValidEmail(String value) => email.hasMatch(value);

  static bool passwordHasLetter(String value) => passwordLetter.hasMatch(value);

  static bool passwordHasNumber(String value) => passwordNumber.hasMatch(value);

  static bool passwordHasMixedCase(String value) =>
      passwordUpper.hasMatch(value) && passwordLower.hasMatch(value);

  static bool passwordHasSymbol(String value) => passwordSymbol.hasMatch(value);
}
