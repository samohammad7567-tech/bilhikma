import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_toast.dart';
import '../cubit/app_update_cubit.dart';
import '../refactor/app_update_blocked_body.dart';

/// Full screen with no way out, for `force_update` and `maintenance`.
///
/// `canPop: false` is the "no close button" requirement taken seriously: the
/// Android back gesture is the close button on this platform, so leaving it
/// enabled would let the user pop straight back into an app that must not run.
class AppUpdateBlockedScreen extends StatelessWidget {
  const AppUpdateBlockedScreen({required this.state, super.key});

  final AppUpdateBlocked state;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocListener<AppUpdateCubit, AppUpdateState>(
          listenWhen: _hasNewError,
          listener: (BuildContext context, AppUpdateState state) =>
              AppToast.error(
                context,
                (state as AppUpdateBlocked).errorKey!.tr(),
              ),
          child: AppUpdateBlockedBody(
            version: state.version,
            onUpdate: () => context.read<AppUpdateCubit>().openStore(),
          ),
        ),
      ),
    );
  }

  static bool _hasNewError(AppUpdateState previous, AppUpdateState current) =>
      current is AppUpdateBlocked &&
      current.errorKey != null &&
      (previous is! AppUpdateBlocked || previous.errorKey != current.errorKey);
}
