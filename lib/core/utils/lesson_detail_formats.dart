class LessonDetailFormats {
  LessonDetailFormats._();
  static String clock(Duration duration) {
    final String minutes = _twoDigits(duration.inMinutes.remainder(60));
    final String seconds = _twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours == 0) return '$minutes:$seconds';
    return '${_twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  static String position({
    required int totalSeconds,
    required int elapsedSeconds,
  }) {
    final int left = totalSeconds - elapsedSeconds;

    return '${clock(Duration(seconds: elapsedSeconds))}'
        '/${clock(Duration(seconds: left < 0 ? 0 : left))}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
