import '../../../../core/constants/cache_keys.dart';
import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/utils/cache_util.dart';

/// Stores the playback rate the user prefers, shared by every audio and
/// video lesson so the choice survives leaving a lesson and the app.
class PlaybackSpeedDataSource {
  const PlaybackSpeedDataSource();

  PlaybackSpeed read() {
    final Object? raw = CacheUtil.get(key: CacheKeys.playbackSpeed);

    return PlaybackSpeed.fromRate(raw is num ? raw.toDouble() : null);
  }

  Future<void> write(PlaybackSpeed speed) =>
      CacheUtil.setDouble(key: CacheKeys.playbackSpeed, value: speed.rate);
}
