import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../cubit/forget_password_cubit.dart';
import '../widgets/back_to_login_row.dart';
import '../widgets/reset_channel_selector.dart';
import '../widgets/reset_identity_field.dart';

class ForgetPasswordForm extends StatelessWidget {
  const ForgetPasswordForm({super.key, this.onBackToLogin});

  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final ForgetPasswordCubit cubit = context.read<ForgetPasswordCubit>();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Form(
      key: cubit.formKey,
      child: BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
        builder: (BuildContext context, ForgetPasswordState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ResetIdentityField(
                channel: state.channel,
                emailController: cubit.emailController,
                phoneController: cubit.phoneController,
              ),

              SizedBox(height: 22.h),

              ResetChannelSelector(
                selected: state.channel,
                onChanged: cubit.selectChannel,
              ),

              SizedBox(height: 34.h),

              CustomButton(
                onPressed: cubit.submit,
                text: 'send_verification_code'.tr(),
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

              SizedBox(height: 16.h),

              BackToLoginRow(onLogin: onBackToLogin),
            ],
          );
        },
      ),
    );
  }
}
