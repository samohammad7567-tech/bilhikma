import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/utils/app_regex.dart';

class ResetPasswordValidators {
  ResetPasswordValidators._();

  static String? password(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) return 'password_required'.tr();
    if (password.length < 8) return 'password_min_8'.tr();
    if (!AppRegex.passwordHasLetter(password)) {
      return 'password_must_contain_letter'.tr();
    }
    if (!AppRegex.passwordHasNumber(password)) {
      return 'password_must_contain_number'.tr();
    }

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
