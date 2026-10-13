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
  static const double maxOnFirstWatch = 1.5;
  static const double maxOnLowEndDevice = 1.25;
  bool get needsCompletedLesson => rate > maxOnFirstWatch;
  bool exceedsDevice({required bool isLowEndDevice}) =>
      isLowEndDevice && rate > maxOnLowEndDevice;
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
