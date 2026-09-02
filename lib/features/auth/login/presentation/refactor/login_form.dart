import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_outline_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/enums/login_method_enum.dart';
import '../cubit/login_cubit.dart';
import '../widgets/login_identity_field.dart';
import '../widgets/login_options_row.dart';
import '../widgets/login_or_divider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key, this.onForgotPassword});

  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final LoginCubit cubit = context.read<LoginCubit>();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Form(
      key: cubit.formKey,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (BuildContext context, LoginState state) {
          return Column(
            key: ValueKey<LoginMethod>(state.method),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LoginIdentityField(
                method: state.method,
                phoneController: cubit.phoneController,
                emailController: cubit.emailController,
              ),
              SizedBox(height: 28.h),
              CustomTextField(
                controller: cubit.passwordController,
                filled: true,
                fillColour: colors.tertiary.withValues(alpha: 0.4),
                hintText: 'password'.tr(),

                suffixIcon: GestureDetector(
                  onTap: cubit.togglePasswordVisibility,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      state.obscurePassword
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,

                      size: 24.w,
                      color: state.obscurePassword
                          ? colors.onSurfaceVariant
                          : colors.secondary,
                    ),
                  ),
                ),

                validator: (value) {
                  final password = value ?? '';

                  if (password.isEmpty) {
                    return 'password_required'.tr();
                  }

                  if (password.length < 6) {
                    return 'password_min_6'.tr();
                  }

                  return null;
                },
                obscureText: state.obscurePassword,
              ),

              SizedBox(height: 42.h),
              LoginOptionsRow(
                rememberMe: state.rememberMe,
                onRememberMeChanged: cubit.toggleRememberMe,
                onForgotPassword: onForgotPassword,
              ),
              SizedBox(height: 32.h),
              CustomButton(
                onPressed: cubit.submit,
                text: 'login'.tr(),
                width: double.infinity,
                height: 40,
                threeRadius: 8.r,
                lastRadius: 8.r,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                elevation: 0,
                isLoading: state.isLoading,
                loadingWidth: 22.w,
                loadingHeight: 22.w,
              ),
              SizedBox(height: 14.h),
              const LoginOrDivider(),
              SizedBox(height: 14.h),
              CustomOutlineButton(
                onPressed: cubit.switchLoginMethod,
                text: state.isEmailLogin
                    ? 'login_with_phone'.tr()
                    : 'login_with_email'.tr(),
                width: double.infinity,
                height: 40,
                threeRadius: 8.r,
                lastRadius: 8.r,
                borderColor: colors.secondary,
                textColor: colors.onSurface,
              ),
            ],
          );
        },
      ),
    );
  }
}
