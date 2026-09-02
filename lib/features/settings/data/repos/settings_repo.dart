import '../data_source/settings_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepo {
  const SettingsRepo({this.dataSource = const SettingsDataSource()});

  final SettingsDataSource dataSource;

  Future<SettingsModel> readSettings() => dataSource.readSettings();

  Future<void> saveFontScale(double scale) => dataSource.saveFontScale(scale);

  Future<void> saveSleepTimer(int minutes) =>
      dataSource.saveSleepTimer(minutes);

  Future<void> clearDownloads() => dataSource.clearDownloads();
}
