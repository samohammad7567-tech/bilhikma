import '../cubit/lesson_detail_cubit.dart';

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
  int get percent => (pending * 100).floor();
  bool get hasPending => pending > confirmed;
}
