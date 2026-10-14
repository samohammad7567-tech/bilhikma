import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_regex.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'field_icon_box.dart';

/// Email is the only recovery channel, so this is the single identity field of
/// the recover-account form.
class ResetIdentityField extends StatelessWidget {
  const ResetIdentityField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return CustomTextField(
      controller: controller,
      filled: true,
      fillColour: colors.tertiary.withValues(alpha: 0.4),
      borderColor: Colors.transparent,
      borderRadius: 12.r,
      hintText: 'email'.tr(),
      textDirection: TextDirection.ltr,
      suffixIcon: const FieldIconBox(asset: AppAssets.assetsEmailIcon),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  static String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'email_required'.tr();
    if (!AppRegex.isValidEmail(email)) return 'valid_email_required'.tr();
    return null;
  }
}
