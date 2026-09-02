import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_regex.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/enums/login_method_enum.dart';

class LoginIdentityField extends StatelessWidget {
  const LoginIdentityField({
    required this.method,
    required this.phoneController,
    required this.emailController,
    super.key,
  });

  final LoginMethod method;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    if (method.isEmail) {
      return CustomTextField(
        filled: true,
        fillColour: colors.tertiary.withValues(alpha: 0.4),
        key: const ValueKey<LoginMethod>(LoginMethod.email),
        controller: emailController,
        hintText: 'email'.tr(),
        suffixIcon: AppIcon(
          size: 20.w,
          padding: EdgeInsetsGeometry.all(12),
          asset: AppAssets.assetsEmailIcon,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
      );
    }

    return CustomTextField(
      filled: true,
      fillColour: colors.tertiary.withValues(alpha: 0.4),
      key: const ValueKey<LoginMethod>(LoginMethod.phone),
      controller: phoneController,
      hintText: 'phone_number'.tr(),
      suffixIcon: AppIcon(
        size: 20.w,
        padding: EdgeInsetsGeometry.all(12),
        asset: AppAssets.assetsPhoneIconFilled,

        color: Theme.of(context).colorScheme.onSurface,
      ),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        final phone = value ?? '';

        if (phone.isEmpty) {
          return 'phone_required'.tr();
        }

        if (!AppRegex.phoneStartsWithZero(phone)) {
          return 'phone_must_start_with_zero'.tr();
        }

        if (!AppRegex.phoneHasValidLength(phone)) {
          return 'phone_must_be_10_digits'.tr();
        }

        return null;
      },
    );
  }

  static String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'email_required'.tr();
    if (!AppRegex.isValidEmail(email)) {
      return 'valid_email_required'.tr();
    }
    return null;
  }
}
