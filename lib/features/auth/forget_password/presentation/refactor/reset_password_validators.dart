import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/enums/password_requirement_enum.dart';

class ResetPasswordValidators {
  ResetPasswordValidators._();

  static String? password(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) return 'password_required'.tr();

    // Rejects on the same rules the checklist renders, so the two can never
    // disagree about whether a password is acceptable.
    final PasswordRequirement? unmet = PasswordRequirement.firstUnsatisfiedIn(
      password,
    );
    if (unmet != null) return unmet.labelKey.tr(namedArgs: unmet.labelArgs);

    return null;
  }

  static String? confirmation(String? value, String password) {
    final String confirmation = value ?? '';

    if (confirmation.isEmpty) {
      return 'password_confirmation_required'.tr();
    }
    if (confirmation != password) return 'passwords_do_not_match'.tr();

    return null;
  }
}
