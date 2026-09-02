import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/settings_cubit.dart';
import '../refactor/settings_body.dart';
import '../../../../core/widgets/app_toast.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => getIt<SettingsCubit>(),
      child: MultiBlocListener(
        listeners: <BlocListener<SettingsCubit, SettingsState>>[
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (SettingsState previous, SettingsState current) =>
                previous.fontScale != current.fontScale,
            listener: (BuildContext context, SettingsState state) => context
                .read<AppPreferencesCubit>()
                .applyFontScale(state.fontScale),
          ),

          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (SettingsState previous, SettingsState current) =>
                current.errorKey != null || current.messageKey != null,
            listener: _showMessage,
          ),
        ],
        child: AppSectionScaffold(
          title: context.tr('settings'),
          child: const SettingsBody(),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, SettingsState state) {
    final String? key = state.errorKey ?? state.messageKey;
    if (key == null) return;

    if (state.errorKey != null) {
      AppToast.error(context, key.tr());
      return;
    }

    AppToast.success(context, key.tr());
  }
}
