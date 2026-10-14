import 'package:bilhikma/core/enums/playback_speed_enum.dart';
import 'package:bilhikma/features/lesson_detail/data/data_source/playback_speed_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlaybackSpeedDataSource store = PlaybackSpeedDataSource();

  setUp(PlaybackSpeedDataSource.clear);

  test('a lesson starts at 1x', () {
    expect(store.read(41), PlaybackSpeed.normal);
  });

  test('every lesson keeps its own speed', () {
    store.write(41, PlaybackSpeed.oneAndThreeQuarters);

    expect(
      store.read(41),
      PlaybackSpeed.oneAndThreeQuarters,
      reason: 'the speed just chosen for this lesson',
    );
    expect(
      store.read(42),
      PlaybackSpeed.normal,
      reason: 'another lesson must not follow that choice',
    );

    store.write(42, PlaybackSpeed.oneAndQuarter);

    expect(store.read(42), PlaybackSpeed.oneAndQuarter);
    expect(
      store.read(41),
      PlaybackSpeed.oneAndThreeQuarters,
      reason: 'the first lesson keeps what it had',
    );
  });

  test('a lesson can be put back to 1x', () {
    store.write(41, PlaybackSpeed.twice);
    store.write(41, PlaybackSpeed.normal);

    expect(store.read(41), PlaybackSpeed.normal);
  });

  test('nothing survives the app being closed', () {
    store.write(41, PlaybackSpeed.twice);
    store.write(42, PlaybackSpeed.half);

    // Which is all a restart is, for a store that only lives in memory.
    PlaybackSpeedDataSource.clear();

    expect(store.read(41), PlaybackSpeed.normal);
    expect(store.read(42), PlaybackSpeed.normal);
  });
}
