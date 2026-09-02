class AppRegex {
  AppRegex._();

  static final RegExp email = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp passwordLetter = RegExp(r'[A-Za-z]');
  static final RegExp passwordNumber = RegExp(r'\d');
  static final RegExp passwordUpper = RegExp('[A-Z]');
  static final RegExp passwordLower = RegExp('[a-z]');
  static final RegExp passwordSymbol = RegExp(r'[^A-Za-z0-9]');

  static bool phoneStartsWithZero(String value) => value.startsWith('0');

  static bool phoneHasValidLength(String value) => value.length == 10;

  static bool isValidEmail(String value) => email.hasMatch(value);

  static bool passwordHasLetter(String value) => passwordLetter.hasMatch(value);

  static bool passwordHasNumber(String value) => passwordNumber.hasMatch(value);

  static bool passwordHasMixedCase(String value) =>
      passwordUpper.hasMatch(value) && passwordLower.hasMatch(value);

  static bool passwordHasSymbol(String value) => passwordSymbol.hasMatch(value);
}
