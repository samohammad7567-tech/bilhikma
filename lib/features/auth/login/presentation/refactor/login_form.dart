import 'package:bilhikma/core/constants/app_assets.dart';
import 'package:bilhikma/core/widgets/app_icon.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_outline_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/enums/login_method_enum.dart';
import '../cubit/login_cubit.dart';
import '../widgets/login_identity_field.dart';
import '../widgets/login_options_row.dart';
import '../widgets/login_or_divider.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key, this.onForgotPassword});

  final void Function(String email)? onForgotPassword;

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
              SizedBox(height: (28).h(context)),
              CustomTextField(
                controller: cubit.passwordController,
                filled: true,
                fillColour: colors.tertiary.withValues(alpha: 0.4),
                hintText: 'password'.tr(),
                textDirection: TextDirection.ltr,

                suffixIcon: GestureDetector(
                  onTap: cubit.togglePasswordVisibility,
                  child: Padding(
                    padding: EdgeInsets.all((12).r(context)),
                    child: AppIcon(
                      size: (20).r(context),
                      asset: AppAssets.assetsLockIcon,
                      color: Theme.of(context).colorScheme.onSurface,
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

              SizedBox(height: (42).h(context)),
              LoginOptionsRow(
                rememberMe: state.rememberMe,
                onRememberMeChanged: cubit.toggleRememberMe,
                onForgotPassword: () =>
                    onForgotPassword?.call(cubit.recoveryEmail),
              ),
              SizedBox(height: (32).h(context)),
              CustomButton(
                onPressed: cubit.submit,
                text: 'login'.tr(),
                width: double.infinity,
                height: (40).h(context),
                threeRadius: 8,
                lastRadius: 8,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                elevation: (0).r(context),
                isLoading: state.isLoading,
                loadingWidth: 22,
                loadingHeight: 22,
              ),
              SizedBox(height: (14).h(context)),
              const LoginOrDivider(),
              SizedBox(height: (14).h(context)),
              CustomOutlineButton(
                onPressed: cubit.switchLoginMethod,
                text: state.isEmailLogin
                    ? 'login_with_phone'.tr()
                    : 'login_with_email'.tr(),
                width: double.infinity,
                height: (40).h(context),
                threeRadius: 8,
                lastRadius: 8,
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
