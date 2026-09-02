import 'package:bilhikma/core/constants/app_assets.dart';
import 'settings_group_enum.dart';

enum SettingsAction {
  fontSize(
    label: 'font_size',
    imagePath: AppAssets.assetsFontSize,
    group: SettingsGroup.audio,
  ),
  sleepTimer(
    label: 'sleep_timer',
    imagePath: AppAssets.assetsSleeperTimerIcon,
    group: SettingsGroup.audio,
  ),
  clearDownloads(
    label: 'clear_downloads',
    imagePath: AppAssets.assetsDeleteIcon,
    group: SettingsGroup.general,
  ),
  shareApp(
    label: 'share_app',
    imagePath: AppAssets.assetsShareAppIcon,
    group: SettingsGroup.general,
  );

  const SettingsAction({
    required this.label,
    required this.imagePath,
    required this.group,
  });
  final String label;

  final String imagePath;

  final SettingsGroup group;
  static List<SettingsAction> of(SettingsGroup group) => SettingsAction.values
      .where((SettingsAction action) => action.group == group)
      .toList(growable: false);
}
