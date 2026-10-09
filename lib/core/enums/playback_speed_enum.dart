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

  /// Rates past the first-watch cap open up once the lesson is completed.
  bool get needsCompletedLesson => rate > maxOnFirstWatch;

  /// Rate to actually play at: a stored preference above the first-watch cap
  /// drops back to the cap until this lesson has been completed.
  PlaybackSpeed cappedFor({required bool isLessonCompleted}) =>
      isLessonCompleted || !needsCompletedLesson
      ? this
      : PlaybackSpeed.oneAndHalf;

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
