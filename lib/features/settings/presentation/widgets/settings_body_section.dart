import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';
import 'settings_section.dart';
import 'settings_tile.dart';
import '../../../../core/enums/settings_action_enum.dart';
import '../refactor/settings_action_handler.dart';
import '../refactor/settings_formats.dart';
import '../../../../core/enums/settings_group_enum.dart';

class SettingsBodySection extends StatelessWidget {
  const SettingsBodySection({
    required this.group,
    required this.state,
    super.key,
  });

  final SettingsGroup group;
  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    return SettingsSection(
      group: group,
      rows: <Widget>[
        for (final SettingsAction action in SettingsAction.of(group))
          SettingsTile(
            action: action,
            value: _valueOf(action),
            isBusy:
                action == SettingsAction.clearDownloads &&
                state.isClearingDownloads,
            onTap: () => SettingsActionHandler.handle(context, cubit, action),
          ),
      ],
    );
  }

  String? _valueOf(SettingsAction action) => switch (action) {
    SettingsAction.fontSize => SettingsFormats.fontScale(
      state.fontScalePercent,
    ),
    SettingsAction.sleepTimer =>
      state.sleepTimer.isOff
          ? null
          : SettingsFormats.sleepTimer(state.sleepTimer),
    SettingsAction.clearDownloads || SettingsAction.shareApp => null,
  };
}
