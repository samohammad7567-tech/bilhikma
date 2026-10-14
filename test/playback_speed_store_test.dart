import 'package:bilhikma/core/constants/cache_keys.dart';
import 'package:bilhikma/core/enums/content_type_enum.dart';
import 'package:bilhikma/core/enums/playback_speed_enum.dart';
import 'package:bilhikma/core/utils/cache_util.dart';
import 'package:bilhikma/features/lesson_detail/data/data_source/playback_speed_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Empties the three keys the store reads, then seeds the one speed the app
/// kept before audio and video were split.
Future<void> _clearStoredSpeeds({double? legacyRate}) async {
  CacheUtil.remove(key: CacheKeys.audioPlaybackSpeed);
  CacheUtil.remove(key: CacheKeys.videoPlaybackSpeed);
  CacheUtil.remove(key: CacheKeys.legacyPlaybackSpeed);

  if (legacyRate == null) return;

  await CacheUtil.setDouble(
    key: CacheKeys.legacyPlaybackSpeed,
    value: legacyRate,
  );
}

void main() {
  const PlaybackSpeedDataSource store = PlaybackSpeedDataSource();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheUtil.init();
  });

  test('audio and video keep their own speed', () async {
    await _clearStoredSpeeds();

    await store.write(ContentType.audio, PlaybackSpeed.oneAndThreeQuarters);

    expect(
      store.read(ContentType.audio),
      PlaybackSpeed.oneAndThreeQuarters,
      reason: 'the speed just chosen for audio',
    );
    expect(
      store.read(ContentType.video),
      PlaybackSpeed.normal,
      reason: 'video must not follow the audio choice',
    );

    await store.write(ContentType.video, PlaybackSpeed.oneAndQuarter);

    expect(store.read(ContentType.video), PlaybackSpeed.oneAndQuarter);
    expect(
      store.read(ContentType.audio),
      PlaybackSpeed.oneAndThreeQuarters,
      reason: 'audio keeps what it had',
    );
  });

  test('a speed stored before the split still applies to both', () async {
    await _clearStoredSpeeds(legacyRate: 1.5);

    expect(store.read(ContentType.audio), PlaybackSpeed.oneAndHalf);
    expect(store.read(ContentType.video), PlaybackSpeed.oneAndHalf);
  });

  test('once a kind has its own speed the old one is ignored', () async {
    await _clearStoredSpeeds(legacyRate: 1.5);

    await store.write(ContentType.audio, PlaybackSpeed.twice);

    expect(store.read(ContentType.audio), PlaybackSpeed.twice);
    expect(
      store.read(ContentType.video),
      PlaybackSpeed.oneAndHalf,
      reason: 'video has not been chosen yet, so it still reads the old speed',
    );
  });

  test('an article falls in with video rather than losing the speed', () async {
    await _clearStoredSpeeds();

    await store.write(ContentType.video, PlaybackSpeed.threeQuarters);

    expect(store.read(ContentType.article), PlaybackSpeed.threeQuarters);
  });
}
