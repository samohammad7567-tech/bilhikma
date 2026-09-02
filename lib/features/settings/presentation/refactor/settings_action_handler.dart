import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/enums/language_option_enum.dart';
import '../../../../core/enums/settings_action_enum.dart';
import '../../../../core/enums/theme_option_enum.dart';
import '../../../../core/widgets/coming_soon_sheet.dart';
import '../../data/data_source/settings_data_source.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/clear_downloads_dialog.dart';
import '../widgets/font_size_sheet.dart';
import '../widgets/sleep_timer_sheet.dart';

class SettingsActionHandler {
  SettingsActionHandler._();

  static void handle(
    BuildContext context,
    SettingsCubit cubit,
    SettingsAction action,
  ) {
    switch (action) {
      case SettingsAction.fontSize:
        FontSizeSheet.show(context, cubit);
      case SettingsAction.sleepTimer:
        SleepTimerSheet.show(context, cubit);
      case SettingsAction.clearDownloads:
        _confirmClearDownloads(context, cubit);
      case SettingsAction.shareApp:
        _shareApp(cubit);
    }
  }

  static Future<void> selectLanguage(
    BuildContext context,
    LanguageOption option,
  ) async {
    if (option.code == context.locale.languageCode) return;

    await context.setLocale(option.locale);
  }

  /// Dark mode is not wired to anything yet, so the segmented control would
  /// otherwise swallow the tap and look broken.
  static void selectTheme(BuildContext context, ThemeOption option) =>
      ComingSoonSheet.show(context, messageKey: 'coming_soon_theme');

  static Future<void> _confirmClearDownloads(
    BuildContext context,
    SettingsCubit cubit,
  ) async {
    final bool isConfirmed = await ClearDownloadsDialog.show(context);

    if (isConfirmed) cubit.clearDownloads();
  }

  static Future<void> _shareApp(SettingsCubit cubit) async {
    await Clipboard.setData(
      const ClipboardData(text: SettingsDataSource.appShareLink),
    );

    cubit.reportMessage('app_link_copied');
  }
}
