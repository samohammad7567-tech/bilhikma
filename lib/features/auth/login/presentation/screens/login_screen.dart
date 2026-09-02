import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../data/models/login_response_model.dart';
import '../cubit/login_cubit.dart';
import '../refactor/login_body.dart';
import '../../../../../core/widgets/app_toast.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onLoggedIn, this.onForgotPassword});

  final void Function(BuildContext context, LoginResponseModel session)?
  onLoggedIn;

  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (LoginState previous, LoginState current) =>
            current.status == LoginStatus.success ||
            current.status == LoginStatus.failure,
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: LoginBody(onForgotPassword: onForgotPassword),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state.status == LoginStatus.failure) {
      final String? errorKey = state.errorKey;
      if (errorKey == null) return;

      AppToast.error(context, errorKey.tr());
      return;
    }

    final LoginResponseModel? session = state.session;
    if (session != null) onLoggedIn?.call(context, session);
  }
}
