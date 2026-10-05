import '../utils/app_regex.dart';

/// The complete set of rules a newly created password must satisfy.
///
/// This is the single source of truth: the checklist UI renders these values
/// and the form validators reject on the same ones, so what the user sees
/// ticked can never disagree with what the form accepts.
enum PasswordRequirement {
  minLength('password_req_min_length'),
  uppercase('password_req_uppercase'),
  lowercase('password_req_lowercase'),
  number('password_req_number'),
  symbol('password_req_symbol');

  const PasswordRequirement(this.labelKey);

  final String labelKey;

  /// Interpolation values for [labelKey], or `null` when it takes none.
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

  /// The first rule [password] breaks, in declaration order, or `null` when it
  /// satisfies all of them.
  static PasswordRequirement? firstUnsatisfiedIn(String password) {
    for (final PasswordRequirement requirement in values) {
      if (!requirement.isSatisfiedBy(password)) return requirement;
    }

    return null;
  }

  static bool allSatisfiedBy(String password) =>
      firstUnsatisfiedIn(password) == null;
}
