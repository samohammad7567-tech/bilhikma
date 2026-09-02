import '../../../../core/constants/cache_keys.dart';
import '../../../../core/utils/cache_util.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../models/settings_model.dart';

class SettingsDataSource {
  const SettingsDataSource({this.downloads = const DownloadedPdfsDataSource()});

  final DownloadedPdfsDataSource downloads;

  static const String appShareLink = 'https://TODO_SET_SHARE_LINK';

  Future<SettingsModel> readSettings() async {
    try {
      return SettingsModel(
        fontScale: readFontScale(),
        sleepTimerMinutes: _readInt(CacheKeys.sleepTimerMinutes),
      );
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  static double readFontScale() {
    final Object? stored = CacheUtil.get(key: CacheKeys.fontScale);
    if (stored is! num) return SettingsModel.defaultFontScale;

    return SettingsModel.normaliseScale(stored.toDouble());
  }

  Future<void> saveFontScale(double scale) async {
    try {
      await CacheUtil.setDouble(
        key: CacheKeys.fontScale,
        value: SettingsModel.normaliseScale(scale),
      );
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  Future<void> saveSleepTimer(int minutes) async {
    try {
      await CacheUtil.setInt(
        key: CacheKeys.sleepTimerMinutes,
        value: minutes < 0 ? 0 : minutes,
      );
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  Future<void> clearDownloads() async {
    try {
      await downloads.clearAll();
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  int _readInt(String key) {
    final Object? stored = CacheUtil.get(key: key);
    return stored is num ? stored.round() : 0;
  }
}
