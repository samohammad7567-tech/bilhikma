import '../../../../core/constants/cache_keys.dart';
import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/utils/cache_util.dart';

class PlaybackSpeedDataSource {
  const PlaybackSpeedDataSource();

  PlaybackSpeed read() {
    final Object? raw = CacheUtil.get(key: CacheKeys.playbackSpeed);

    return PlaybackSpeed.fromRate(raw is num ? raw.toDouble() : null);
  }

  Future<void> write(PlaybackSpeed speed) =>
      CacheUtil.setDouble(key: CacheKeys.playbackSpeed, value: speed.rate);
}
