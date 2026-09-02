import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../cubit/set_password_cubit.dart';
import '../refactor/set_password_args.dart';
import '../refactor/set_password_body.dart';
import '../../../../../core/widgets/app_toast.dart';

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({required this.args, super.key, this.onPasswordSet});

  final SetPasswordArgs args;

  final void Function(BuildContext context)? onPasswordSet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetPasswordCubit>(
      create: (_) => getIt<SetPasswordCubit>(param1: args),
      child: BlocListener<SetPasswordCubit, SetPasswordState>(
        listenWhen: (SetPasswordState previous, SetPasswordState current) =>
            current.status == SetPasswordStatus.success ||
            current.status == SetPasswordStatus.failure,
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: const SetPasswordBody(),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SetPasswordState state) {
    if (state.status == SetPasswordStatus.failure) {
      final String? errorKey = state.errorKey;
      if (errorKey == null) return;

      AppToast.error(context, errorKey.tr());
      return;
    }

    AppToast.success(context, 'password_reset_success'.tr());
    onPasswordSet?.call(context);
  }
}
