import 'package:bilhikma/core/enums/playback_speed_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only rates past 1.5x wait for the lesson to be completed', () {
    expect(
      PlaybackSpeed.values
          .where((PlaybackSpeed speed) => speed.needsCompletedLesson)
          .toList(),
      <PlaybackSpeed>[
        PlaybackSpeed.oneAndThreeQuarters,
        PlaybackSpeed.twice,
      ],
    );
  });

  test('first watch caps a faster stored preference at 1.5x', () {
    for (final PlaybackSpeed speed in PlaybackSpeed.values) {
      final PlaybackSpeed capped = speed.cappedFor(isLessonCompleted: false);

      expect(capped.rate, lessThanOrEqualTo(PlaybackSpeed.maxOnFirstWatch));
      // Anything at or below the cap is left alone.
      if (!speed.needsCompletedLesson) expect(capped, speed);
    }

    expect(
      PlaybackSpeed.twice.cappedFor(isLessonCompleted: false),
      PlaybackSpeed.oneAndHalf,
    );
  });

  test('a completed lesson keeps every rate as chosen', () {
    for (final PlaybackSpeed speed in PlaybackSpeed.values) {
      expect(speed.cappedFor(isLessonCompleted: true), speed);
    }
  });

  test('a stored rate snaps to the nearest offered one', () {
    expect(PlaybackSpeed.fromRate(null), PlaybackSpeed.normal);
    expect(PlaybackSpeed.fromRate(1.5), PlaybackSpeed.oneAndHalf);
    expect(PlaybackSpeed.fromRate(1.6), PlaybackSpeed.oneAndHalf);
    expect(PlaybackSpeed.fromRate(3), PlaybackSpeed.twice);
  });
}
