/// Playback rates offered for audio and video lessons.
///
/// The labels are deliberately numeric so they read the same in both
/// languages; only the normal rate gets a translated label in pickers.
enum PlaybackSpeed {
  half(0.5, '0.5x'),
  threeQuarters(0.75, '0.75x'),
  normal(1, '1x'),
  oneAndQuarter(1.25, '1.25x'),
  oneAndHalf(1.5, '1.5x'),
  oneAndThreeQuarters(1.75, '1.75x'),
  twice(2, '2x');

  const PlaybackSpeed(this.rate, this.label);

  final double rate;

  final String label;

  bool get isNormal => this == PlaybackSpeed.normal;

  /// Fastest rate allowed before the lesson has been completed once.
  static const double maxOnFirstWatch = 1.5;

  /// Fastest rate a low-end device is asked to sustain.
  ///
  /// A decoder that only just keeps up at 1x has no headroom above it: it
  /// misses its frame deadlines and ExoPlayer aborts the stream with a
  /// `MediaCodec` error rather than merely playing rough. Older hardware also
  /// runs the audio rate change through `Sonic` on the CPU, which competes
  /// with the decoder for the same budget.
  static const double maxOnLowEndDevice = 1.25;

  /// Rates past the first-watch cap open up once the lesson is completed.
  bool get needsCompletedLesson => rate > maxOnFirstWatch;

  /// True when this device should not be asked for this rate at all. Unlike
  /// [needsCompletedLesson] the user cannot unlock it — the hardware is the
  /// limit.
  bool exceedsDevice({required bool isLowEndDevice}) =>
      isLowEndDevice && rate > maxOnLowEndDevice;

  /// Rate to actually play at, after both caps.
  ///
  /// The device cap is applied last and wins: a rate the hardware cannot
  /// decode is not worth attempting however far the user has got through the
  /// lesson.
  PlaybackSpeed cappedFor({
    required bool isLessonCompleted,
    required bool isLowEndDevice,
  }) {
    final PlaybackSpeed allowed = isLessonCompleted || !needsCompletedLesson
        ? this
        : PlaybackSpeed.oneAndHalf;

    return allowed.exceedsDevice(isLowEndDevice: isLowEndDevice)
        ? PlaybackSpeed.oneAndQuarter
        : allowed;
  }

  /// Closest offered rate to [rate]; [normal] when nothing was stored.
  ///
  /// Keeps a cached rate usable after this list changes, instead of silently
  /// dropping back to normal speed.
  static PlaybackSpeed fromRate(double? rate) {
    if (rate == null) return PlaybackSpeed.normal;

    PlaybackSpeed closest = PlaybackSpeed.normal;
    double smallestGap = (closest.rate - rate).abs();

    for (final PlaybackSpeed option in PlaybackSpeed.values) {
      final double gap = (option.rate - rate).abs();
      if (gap >= smallestGap) continue;

      closest = option;
      smallestGap = gap;
    }

    return closest;
  }
}
