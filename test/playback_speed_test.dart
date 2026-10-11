import 'package:bilhikma/core/enums/playback_speed_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('first-watch cap', () {
    test('only rates past 1.5x wait for the lesson to be completed', () {
      expect(
        PlaybackSpeed.values
            .where((PlaybackSpeed speed) => speed.needsCompletedLesson)
            .toList(),
        <PlaybackSpeed>[PlaybackSpeed.oneAndThreeQuarters, PlaybackSpeed.twice],
      );
    });

    test('first watch caps a faster stored preference at 1.5x', () {
      for (final PlaybackSpeed speed in PlaybackSpeed.values) {
        final PlaybackSpeed capped = speed.cappedFor(
          isLessonCompleted: false,
          isLowEndDevice: false,
        );

        expect(capped.rate, lessThanOrEqualTo(PlaybackSpeed.maxOnFirstWatch));
        // Anything at or below the cap is left alone.
        if (!speed.needsCompletedLesson) expect(capped, speed);
      }

      expect(
        PlaybackSpeed.twice.cappedFor(
          isLessonCompleted: false,
          isLowEndDevice: false,
        ),
        PlaybackSpeed.oneAndHalf,
      );
    });

    test('a completed lesson keeps every rate as chosen', () {
      for (final PlaybackSpeed speed in PlaybackSpeed.values) {
        expect(
          speed.cappedFor(isLessonCompleted: true, isLowEndDevice: false),
          speed,
        );
      }
    });
  });

  group('device cap', () {
    test('only rates past 1.25x exceed a low-end device', () {
      expect(
        PlaybackSpeed.values
            .where(
              (PlaybackSpeed speed) =>
                  speed.exceedsDevice(isLowEndDevice: true),
            )
            .toList(),
        <PlaybackSpeed>[
          PlaybackSpeed.oneAndHalf,
          PlaybackSpeed.oneAndThreeQuarters,
          PlaybackSpeed.twice,
        ],
      );
    });

    test('a capable device is never capped', () {
      for (final PlaybackSpeed speed in PlaybackSpeed.values) {
        expect(speed.exceedsDevice(isLowEndDevice: false), isFalse);
      }
    });

    test('a low-end device never plays above 1.25x', () {
      for (final PlaybackSpeed speed in PlaybackSpeed.values) {
        for (final bool completed in <bool>[false, true]) {
          final PlaybackSpeed capped = speed.cappedFor(
            isLessonCompleted: completed,
            isLowEndDevice: true,
          );

          expect(
            capped.rate,
            lessThanOrEqualTo(PlaybackSpeed.maxOnLowEndDevice),
            reason: '$speed with isLessonCompleted: $completed',
          );
        }
      }
    });

    test('the device cap wins over a completed lesson', () {
      // Completing the lesson unlocks 2x, but the hardware still cannot hold
      // it — and unlike the first-watch cap, the user cannot lift this one.
      expect(
        PlaybackSpeed.twice.cappedFor(
          isLessonCompleted: true,
          isLowEndDevice: true,
        ),
        PlaybackSpeed.oneAndQuarter,
      );
    });

    test('a low-end device keeps slower rates exactly as chosen', () {
      for (final PlaybackSpeed speed in <PlaybackSpeed>[
        PlaybackSpeed.half,
        PlaybackSpeed.threeQuarters,
        PlaybackSpeed.normal,
        PlaybackSpeed.oneAndQuarter,
      ]) {
        expect(
          speed.cappedFor(isLessonCompleted: false, isLowEndDevice: true),
          speed,
        );
      }
    });
  });

  test('a stored rate snaps to the nearest offered one', () {
    expect(PlaybackSpeed.fromRate(null), PlaybackSpeed.normal);
    expect(PlaybackSpeed.fromRate(1.5), PlaybackSpeed.oneAndHalf);
    expect(PlaybackSpeed.fromRate(1.6), PlaybackSpeed.oneAndHalf);
    expect(PlaybackSpeed.fromRate(3), PlaybackSpeed.twice);
  });
}
