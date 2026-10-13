import '../utils/app_regex.dart';

enum PasswordRequirement {
  minLength('password_req_min_length'),
  uppercase('password_req_uppercase'),
  lowercase('password_req_lowercase'),
  number('password_req_number'),
  symbol('password_req_symbol');

  const PasswordRequirement(this.labelKey);

  final String labelKey;
  Map<String, String>? get labelArgs => switch (this) {
    PasswordRequirement.minLength => <String, String>{
      'count': '${AppRegex.passwordMinLength}',
    },
    _ => null,
  };

  bool isSatisfiedBy(String password) => switch (this) {
    PasswordRequirement.minLength => AppRegex.passwordHasMinLength(password),
    PasswordRequirement.uppercase => AppRegex.passwordHasUpper(password),
    PasswordRequirement.lowercase => AppRegex.passwordHasLower(password),
    PasswordRequirement.number => AppRegex.passwordHasNumber(password),
    PasswordRequirement.symbol => AppRegex.passwordHasSymbol(password),
  };
  static PasswordRequirement? firstUnsatisfiedIn(String password) {
    for (final PasswordRequirement requirement in values) {
      if (!requirement.isSatisfiedBy(password)) return requirement;
    }

    return null;
  }

  static bool allSatisfiedBy(String password) =>
      firstUnsatisfiedIn(password) == null;
}
