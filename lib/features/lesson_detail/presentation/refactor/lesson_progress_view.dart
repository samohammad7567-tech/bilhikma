import '../cubit/lesson_detail_cubit.dart';

/// UI-ready progress numbers for the lesson summary card.
///
/// Carries both tracks: [confirmed] is what the server credited, [pending] is
/// the optimistic local value shown between checkpoints. Widgets render them,
/// nothing else reads them.
class LessonProgressView {
  const LessonProgressView({
    required this.totalSeconds,
    required this.elapsedSeconds,
    required this.confirmed,
    required this.pending,
  });

  factory LessonProgressView.of(LessonDetailState state) => LessonProgressView(
    totalSeconds: state.detail?.durationSeconds ?? 0,
    elapsedSeconds: state.watchedHighWaterSeconds,
    confirmed: state.confirmedProgress,
    pending: state.displayProgress,
  );

  final int totalSeconds;

  final int elapsedSeconds;

  final double confirmed;

  final double pending;

  /// Rounded down so the label never reads 100% before the final checkpoint
  /// has actually been acknowledged.
  int get percent => (pending * 100).floor();

  /// True while local playback is ahead of what the server has credited.
  bool get hasPending => pending > confirmed;
}
