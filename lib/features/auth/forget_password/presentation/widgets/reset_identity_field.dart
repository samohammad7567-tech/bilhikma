import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_regex.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/phone_number_field.dart';
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

    return PhoneNumberField(
      key: const ValueKey<ResetChannel>(ResetChannel.sms),
      controller: phoneController,
      fillColour: fill,
      borderColor: Colors.transparent,
      borderRadius: 12.r,
      suffixIcon: const FieldIconBox(asset: AppAssets.assetsPhoneIconFilled),
    );
  }

  static String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'email_required'.tr();
    if (!AppRegex.isValidEmail(email)) return 'valid_email_required'.tr();
    return null;
  }
}
