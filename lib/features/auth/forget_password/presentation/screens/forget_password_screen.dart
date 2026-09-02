import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../cubit/forget_password_cubit.dart';
import '../refactor/forget_password_body.dart';
import '../refactor/set_password_args.dart';
import '../../../../../core/widgets/app_toast.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key, this.onCodeSent, this.onBackToLogin});

  final void Function(BuildContext context, SetPasswordArgs args)? onCodeSent;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgetPasswordCubit>(
      create: (_) => getIt<ForgetPasswordCubit>(),
      child: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
        listenWhen:
            (ForgetPasswordState previous, ForgetPasswordState current) =>
                current.status == ForgetPasswordStatus.success ||
                current.status == ForgetPasswordStatus.failure,
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: ForgetPasswordBody(onBackToLogin: onBackToLogin),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ForgetPasswordState state) {
    if (state.status == ForgetPasswordStatus.failure) {
      final String? errorKey = state.errorKey;
      if (errorKey == null) return;

      AppToast.error(context, errorKey.tr());
      return;
    }

    AppToast.success(context, 'reset_code_sent'.tr());

    onCodeSent?.call(
      context,
      SetPasswordArgs(identifier: state.identifier, channel: state.channel),
    );
  }
}
