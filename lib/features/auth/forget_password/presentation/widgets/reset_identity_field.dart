import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_regex.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/enums/reset_channel_enum.dart';
import 'field_icon_box.dart';

class ResetIdentityField extends StatelessWidget {
  const ResetIdentityField({
    required this.channel,
    required this.emailController,
    required this.phoneController,
    super.key,
  });

  final ResetChannel channel;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color fill = colors.tertiary.withValues(alpha: 0.4);

    if (channel.isEmail) {
      return CustomTextField(
        key: const ValueKey<ResetChannel>(ResetChannel.email),
        controller: emailController,
        filled: true,
        fillColour: fill,
        borderColor: Colors.transparent,
        borderRadius: 12.r,
        hintText: 'email'.tr(),
        suffixIcon: const FieldIconBox(asset: AppAssets.assetsEmailIcon),
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
      );
    }

    return CustomTextField(
      key: const ValueKey<ResetChannel>(ResetChannel.sms),
      controller: phoneController,
      filled: true,
      fillColour: fill,
      borderColor: Colors.transparent,
      borderRadius: 12.r,
      hintText: 'phone_number'.tr(),
      suffixIcon: const FieldIconBox(asset: AppAssets.assetsPhoneIconFilled),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: _validatePhone,
    );
  }

  static String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'email_required'.tr();
    if (!AppRegex.isValidEmail(email)) return 'valid_email_required'.tr();
    return null;
  }

  static String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'phone_required'.tr();
    if (!AppRegex.phoneStartsWithZero(phone)) {
      return 'phone_must_start_with_zero'.tr();
    }
    if (!AppRegex.phoneHasValidLength(phone)) {
      return 'phone_must_be_10_digits'.tr();
    }
    return null;
  }
}
