import '../../../../core/enums/playback_speed_enum.dart';

/// Remembers the speed each lesson is being followed at, for as long as the
/// app is running.
///
/// The speed belongs to the lesson rather than to the student: picking 1.75x
/// to get through one lesson says nothing about the next, so every lesson
/// keeps its own choice and none of them moves another. Nothing is written to
/// disk either — closing the app puts every lesson back to 1x.
class PlaybackSpeedDataSource {
  const PlaybackSpeedDataSource();

  /// Held in memory and keyed by lesson, so a choice survives leaving the
  /// screen and coming back within the same run, and dies with the process.
  static final Map<int, PlaybackSpeed> _speeds = <int, PlaybackSpeed>{};

  PlaybackSpeed read(int lessonId) => _speeds[lessonId] ?? PlaybackSpeed.normal;

  void write(int lessonId, PlaybackSpeed speed) {
    // 1x is what a lesson starts at, so there is nothing to remember for it.
    if (speed.isNormal) {
      _speeds.remove(lessonId);
      return;
    }

    _speeds[lessonId] = speed;
  }

  /// Forgets every lesson's speed. Closing the app does this on its own, the
  /// store being memory only; the tests use it to stand in for a restart.
  static void clear() => _speeds.clear();
}
