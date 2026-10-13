import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/app_update_cubit.dart';
import 'app_update_blocked_screen.dart';

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
