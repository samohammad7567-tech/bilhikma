import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/app_update_cubit.dart';
import 'app_update_blocked_screen.dart';

/// Wraps the first route and decides whether the app may be shown at all.
///
/// The check is started here, in parallel with whatever [child] is doing, so it
/// adds nothing to the time the user waits. The moment a blocking verdict
/// arrives the child is replaced — a user on an unusable build should not sit
/// through the rest of the splash to be told so.
///
/// The non-blocking half of the verdict is not handled here: see
/// `AppUpdateFlow.resolve`, which the splash hand-off awaits.
class AppUpdateGate extends StatelessWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppUpdateCubit>(
      create: (_) => getIt<AppUpdateCubit>()..check(),
      child: BlocBuilder<AppUpdateCubit, AppUpdateState>(
        buildWhen: (AppUpdateState previous, AppUpdateState current) =>
            (previous is AppUpdateBlocked) != (current is AppUpdateBlocked),
        builder: (BuildContext context, AppUpdateState state) =>
            state is AppUpdateBlocked
            ? AppUpdateBlockedScreen(state: state)
            : child,
      ),
    );
  }
}
