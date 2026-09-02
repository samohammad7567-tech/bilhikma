import 'package:bilhikma/core/constants/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/enums/language_option_enum.dart';
import '../refactor/settings_action_handler.dart';
import 'settings_choice_card.dart';
import 'settings_segmented_control.dart';

class SettingsLanguageCard extends StatelessWidget {
  const SettingsLanguageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsChoiceCard(
      imagePath: AppAssets.assetsLanguageIcon,
      title: 'app_language',
      hint: 'app_language_hint',
      control: SettingsSegmentedControl<LanguageOption>(
        options: LanguageOption.values,
        selected: LanguageOption.of(context.locale.languageCode),
        labelOf: (LanguageOption option) => option.label.tr(),
        onSelected: (LanguageOption option) =>
            SettingsActionHandler.selectLanguage(context, option),
      ),
    );
  }
}
