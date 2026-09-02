import '../utils/app_regex.dart';

enum PasswordStrength {
  none(0, ''),
  weak(1, 'password_strength_weak'),
  fair(2, 'password_strength_fair'),
  good(3, 'password_strength_good'),
  strong(4, 'password_strength_strong');

  const PasswordStrength(this.filledSegments, this.labelKey);

  final int filledSegments;
  final String labelKey;

  static const int segments = 4;

  bool get isEmpty => this == PasswordStrength.none;

  static PasswordStrength of(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;
    if (password.length >= 8) score++;
    if (AppRegex.passwordHasLetter(password) &&
        AppRegex.passwordHasNumber(password)) {
      score++;
    }
    if (AppRegex.passwordHasMixedCase(password)) score++;
    if (AppRegex.passwordHasSymbol(password) || password.length >= 12) score++;

    return switch (score) {
      >= 4 => PasswordStrength.strong,
      3 => PasswordStrength.good,
      2 => PasswordStrength.fair,
      _ => PasswordStrength.weak,
    };
  }
}
