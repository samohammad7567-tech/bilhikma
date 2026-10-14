import '../../../../core/constants/cache_keys.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/enums/playback_speed_enum.dart';
import '../../../../core/utils/cache_util.dart';

/// Remembers the playback speed per kind of media.
///
/// Listening and watching are different habits — a lesson followed at 1.75x on
/// audio should not start the next video at 1.75x — so each kind keeps its own
/// speed and neither moves the other.
class PlaybackSpeedDataSource {
  const PlaybackSpeedDataSource();

  PlaybackSpeed read(ContentType type) {
    final Object? stored = CacheUtil.get(key: _keyFor(type));
    if (stored is num) return PlaybackSpeed.fromRate(stored.toDouble());

    return PlaybackSpeed.fromRate(_legacyRate());
  }

  Future<void> write(ContentType type, PlaybackSpeed speed) =>
      CacheUtil.setDouble(key: _keyFor(type), value: speed.rate);

  /// The speed both players shared before they were split, used only until the
  /// student picks one for this kind of media.
  double? _legacyRate() {
    final Object? legacy = CacheUtil.get(key: CacheKeys.legacyPlaybackSpeed);

    return legacy is num ? legacy.toDouble() : null;
  }

  static String _keyFor(ContentType type) => type.isAudio
      ? CacheKeys.audioPlaybackSpeed
      : CacheKeys.videoPlaybackSpeed;
}
