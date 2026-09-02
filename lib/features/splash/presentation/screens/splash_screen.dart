import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/splash_cubit.dart';
import '../refactor/splash_body.dart';
import '../../../../core/widgets/app_toast.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onCompleted});

  final void Function(BuildContext context, bool isLoggedIn)? onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => getIt<SplashCubit>()..start(),
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (previous, current) => current is SplashCompleted,
        listener: (BuildContext context, SplashState state) {
          final SplashCompleted completed = state as SplashCompleted;
          _showNotice(context, completed.noticeKey);
          onCompleted?.call(context, completed.isLoggedIn);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColorLight,
          body: const SplashBody(),
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String? noticeKey) {
    if (noticeKey == null) return;

    AppToast.show(context, noticeKey.tr());
  }
}
