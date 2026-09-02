import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../widgets/main_shell_view.dart';
import '../../../../core/widgets/app_toast.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsCubit>.value(
      value: getIt<NotificationsCubit>(),
      child: MainShellView(onBack: _onBack),
    );
  }

  void _onBack(BuildContext context, ShellBackAction action) {
    switch (action) {
      case ShellBackAction.none:
        return;
      case ShellBackAction.exit:
        SystemNavigator.pop();
      case ShellBackAction.confirmExit:
        AppToast.show(
          context,
          'press_back_again_to_exit'.tr(),
          duration: AppPreferencesCubit.exitWindow,
        );
    }
  }
}
