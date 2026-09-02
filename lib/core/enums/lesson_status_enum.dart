enum LessonStatus {
  available,
  inProgress,
  locked,
  completed;

  bool get showsProgress => this == LessonStatus.inProgress;
  bool get isLocked => this == LessonStatus.locked;

  bool get isCompleted => this == LessonStatus.completed;

  static LessonStatus resolve({
    required bool isCompleted,
    required bool isStarted,
    required bool isLocked,
  }) {
    if (isCompleted) return LessonStatus.completed;
    if (isLocked) return LessonStatus.locked;

    if (isStarted) return LessonStatus.inProgress;
    return LessonStatus.available;
  }
}
