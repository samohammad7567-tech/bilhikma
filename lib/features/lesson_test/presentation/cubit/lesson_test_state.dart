part of 'lesson_test_cubit.dart';

enum LessonTestStatus {
  initial,
  loading,
  ready,
  starting,
  running,
  submitting,
  result,
  failure,
}

enum LessonTestPhase { intro, running, result }

final class LessonTestState {
  const LessonTestState({
    this.status = LessonTestStatus.initial,
    this.quiz,
    this.attempt,
    this.answers = const <String, TestAnswerModel>{},
    this.rightOrder = const <String, List<String>>{},
    this.currentIndex = 0,
    this.remaining = Duration.zero,
    this.questionStartedAt,
    this.questionTick = 0,
    this.selectedBlankId,
    this.selectedPromptId,
    this.errorKey,
    this.messageKey,
    this.validationErrors = const <String, List<String>>{},
    this.nextLessonId,
    this.nextLessonTitle,
    this.nextLessonLocked = false,
    this.isStarting = false,
    this.isSubmitting = false,
    this.result,
  });

  final LessonTestStatus status;
  final LessonTestModel? quiz;
  final QuizAttemptModel? attempt;

  final Map<String, TestAnswerModel> answers;
  final Map<String, List<String>> rightOrder;

  final int currentIndex;
  final Duration remaining;
  final DateTime? questionStartedAt;
  final int questionTick;

  final String? selectedBlankId;
  final String? selectedPromptId;

  final String? errorKey;
  final String? messageKey;
  final Map<String, List<String>> validationErrors;

  final int? nextLessonId;
  final String? nextLessonTitle;
  final bool nextLessonLocked;

  final bool isStarting;
  final bool isSubmitting;
  final QuizAttemptModel? result;

  bool get isLoading =>
      status == LessonTestStatus.loading || status == LessonTestStatus.initial;

  bool get hasFailed => status == LessonTestStatus.failure;

  bool get isReady => status == LessonTestStatus.ready;

  bool get isRunning => status == LessonTestStatus.running;

  bool get isSubmittingState => status == LessonTestStatus.submitting;

  bool get isResult => status == LessonTestStatus.result;

  bool get hasQuiz => quiz != null;

  bool get hasQuestions => attempt?.questions.isNotEmpty ?? false;

  bool get hasTimeLimit =>
      attempt?.expiresAt != null || (quiz?.hasTimeLimit ?? false);

  bool get canStart =>
      quiz != null &&
      status != LessonTestStatus.running &&
      status != LessonTestStatus.submitting &&
      status != LessonTestStatus.result &&
      !isStarting &&
      (quiz?.hasAttemptsLeft ?? false) &&
      !(quiz?.isInCooldown ?? true) &&
      (quiz?.questionCount ?? 0) > 0;

  bool get isFirstQuestion => currentIndex == 0;

  bool get isLastQuestion =>
      questionCount == 0 || currentIndex >= questionCount - 1;

  int get questionCount =>
      attempt?.questions.length ?? quiz?.questionCount ?? 0;

  double get progress =>
      questionCount == 0 ? 0 : (currentIndex + 1) / questionCount;

  Duration get questionElapsed => questionStartedAt == null
      ? Duration.zero
      : DateTime.now().difference(questionStartedAt!);

  Duration? get questionRemaining {
    final Duration? limit = currentQuestion?.timeLimit;
    if (limit == null) return null;

    final Duration left = limit - questionElapsed;
    return left.isNegative ? Duration.zero : left;
  }

  TestQuestionModel? get currentQuestion {
    final List<TestQuestionModel> questions =
        attempt?.questions ?? const <TestQuestionModel>[];
    return currentIndex >= 0 && currentIndex < questions.length
        ? questions[currentIndex]
        : null;
  }

  TestAnswerModel get currentAnswer =>
      answers[currentQuestion?.id] ?? const TestAnswerModel();

  TestAnswerModel answerOf(String questionId) =>
      answers[questionId] ?? const TestAnswerModel();

  List<String> rightOrderOf(String questionId) =>
      rightOrder[questionId] ?? const <String>[];

  bool get isPassed => result?.isPassed ?? quiz?.hasPassed ?? false;

  bool get canGoToNextLesson {
    final QuizAttemptModel? result = this.result;
    if (result == null) return false;

    if (result.isPendingReview) return false;
    if (result.isPassed == true) return true;

    return !(quiz?.isBlocking ?? false);
  }

  @Deprecated('Legacy UI alias; use quiz.')
  LessonTestModel? get test => quiz;

  @Deprecated('Legacy UI alias; use status/isRunning/isResult.')
  LessonTestPhase get phase {
    if (status == LessonTestStatus.result) return LessonTestPhase.result;
    if (status == LessonTestStatus.running ||
        status == LessonTestStatus.starting ||
        status == LessonTestStatus.submitting) {
      return LessonTestPhase.running;
    }
    return LessonTestPhase.intro;
  }

  @Deprecated('Legacy UI alias; use rightOrder.')
  Map<String, List<String>> get matchOrder => rightOrder;

  @Deprecated('Legacy UI alias; use rightOrderOf.')
  List<String> matchOrderOf(String questionId) => rightOrderOf(questionId);

  LessonTestState copyWith({
    LessonTestStatus? status,
    LessonTestModel? quiz,
    QuizAttemptModel? attempt,
    Map<String, TestAnswerModel>? answers,
    Map<String, List<String>>? rightOrder,
    int? currentIndex,
    Duration? remaining,
    DateTime? questionStartedAt,
    int? questionTick,
    String? selectedBlankId,
    String? selectedPromptId,
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
    String? errorKey,
    bool clearError = false,
    String? messageKey,
    bool clearMessage = false,
    Map<String, List<String>>? validationErrors,
    int? nextLessonId,
    String? nextLessonTitle,
    bool? nextLessonLocked,
    bool clearNextLesson = false,
    bool? isStarting,
    bool? isSubmitting,
    QuizAttemptModel? result,
  }) => LessonTestState(
    status: status ?? this.status,
    quiz: quiz ?? this.quiz,
    attempt: attempt ?? this.attempt,
    answers: answers ?? this.answers,
    rightOrder: rightOrder ?? this.rightOrder,
    currentIndex: currentIndex ?? this.currentIndex,
    remaining: remaining ?? this.remaining,
    questionStartedAt: questionStartedAt ?? this.questionStartedAt,
    questionTick: questionTick ?? this.questionTick,
    selectedBlankId: clearSelectedBlank
        ? null
        : selectedBlankId ?? this.selectedBlankId,
    selectedPromptId: clearSelectedPrompt
        ? null
        : selectedPromptId ?? this.selectedPromptId,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    messageKey: clearMessage ? null : messageKey ?? this.messageKey,
    validationErrors: clearError
        ? const <String, List<String>>{}
        : validationErrors ?? this.validationErrors,
    nextLessonId: clearError || clearNextLesson
        ? null
        : nextLessonId ?? this.nextLessonId,
    nextLessonTitle: clearError || clearNextLesson
        ? null
        : nextLessonTitle ?? this.nextLessonTitle,
    nextLessonLocked: clearError || clearNextLesson
        ? false
        : nextLessonLocked ?? this.nextLessonLocked,
    isStarting: isStarting ?? this.isStarting,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    result: result ?? this.result,
  );
}
