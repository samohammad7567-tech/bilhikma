import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'field_icon_box.dart';

class ResetPasswordField extends StatelessWidget {
  const ResetPasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    super.key,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return CustomTextField(
      controller: controller,
      filled: true,
      fillColour: colors.tertiary.withValues(alpha: 0.4),
      borderColor: Colors.transparent,
      borderRadius: 12.r,
      hintText: 'password'.tr(),
      obscureText: obscure,
      validator: validator,
      onChanged: (String? value) {
        onChanged?.call(value ?? '');
        return null;
      },
      suffixIcon: FieldIconBox(
        asset: AppAssets.assetsLockIcon,
        onTap: onToggle,
      ),
    );
  }
}
