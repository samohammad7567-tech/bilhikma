import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../cubit/set_password_cubit.dart';
import '../widgets/labelled_field.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/reset_password_field.dart';
import 'reset_password_validators.dart';

class SetPasswordForm extends StatelessWidget {
  const SetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final SetPasswordCubit cubit = context.read<SetPasswordCubit>();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return BlocBuilder<SetPasswordCubit, SetPasswordState>(
      builder: (BuildContext context, SetPasswordState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OtpCodeField(
              controller: cubit.codeController,
              length: cubit.codeLength,
              onChanged: cubit.codeChanged,
              errorKey: state.codeErrorKey,
              isVerifying: state.isVerifyingCode,
              isVerified: state.isCodeVerified,
            ),

            SizedBox(height: 20.h),

            Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LabelledField(
                    labelKey: 'new_password_label',
                    child: ResetPasswordField(
                      controller: cubit.passwordController,
                      obscure: state.obscurePassword,
                      onToggle: cubit.togglePasswordVisibility,
                      onChanged: cubit.passwordChanged,
                      validator: ResetPasswordValidators.password,
                    ),
                  ),

                  if (state.showStrength) ...<Widget>[
                    SizedBox(height: 10.h),
                    PasswordStrengthMeter(strength: state.strength),
                  ],

                  SizedBox(height: 18.h),

                  LabelledField(
                    labelKey: 'confirm_new_password_label',
                    child: ResetPasswordField(
                      controller: cubit.confirmController,
                      obscure: state.obscureConfirm,
                      onToggle: cubit.toggleConfirmVisibility,
                      validator: (String? value) =>
                          ResetPasswordValidators.confirmation(
                            value,
                            cubit.passwordController.text,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            CustomButton(
              onPressed: cubit.submit,
              text: 'confirm_save_and_login'.tr(),
              width: double.infinity,
              height: 46.h,
              threeRadius: 8.r,
              lastRadius: 8.r,
              backgroundColor: colors.secondary,
              textColor: colors.onSecondary,
              elevation: 0,
              isLoading: state.isLoading,
              loadingWidth: 22.w,
              loadingHeight: 22.w,
            ),
          ],
        );
      },
    );
  }
}
