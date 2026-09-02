import 'package:bilhikma/core/constants/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/enums/theme_option_enum.dart';
import '../refactor/settings_action_handler.dart';
import 'settings_choice_card.dart';
import 'settings_segmented_control.dart';

class SettingsThemeCard extends StatelessWidget {
  const SettingsThemeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      builder: (BuildContext context, AppPreferencesState state) {
        final ThemeOption selected = ThemeOption.of(
          context.read<AppPreferencesCubit>().isDark,
        );

        return SettingsChoiceCard(
          imagePath: AppAssets.assetsThemeIcon,
          title: 'app_theme',
          hint: 'app_theme_hint',
          control: SettingsSegmentedControl<ThemeOption>(
            options: ThemeOption.values,
            selected: selected,
            labelOf: (ThemeOption option) => option.label.tr(),
            iconOf: (ThemeOption option) => option.icon,
            onSelected: (ThemeOption option) =>
                SettingsActionHandler.selectTheme(context, option),
          ),
        );
      },
    );
  }
}
