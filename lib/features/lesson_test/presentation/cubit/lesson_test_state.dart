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

enum LessonTestSaveStatus { idle, saving, saved, failed }

final class LessonTestState {
  const LessonTestState({
    this.status = LessonTestStatus.initial,
    this.quiz,
    this.attempt,
    this.answers = const <String, TestAnswerModel>{},
    this.rightOrder = const <String, List<String>>{},
    this.currentIndex = 0,
    this.remaining = Duration.zero,
    this.questionTick = 0,
    this.questionTimers = const <String, QuestionTimerModel>{},
    this.openedQuestionIds = const <String>{},
    this.lockedQuestionIds = const <String>{},
    this.openingQuestionId,
    this.clockOffset = Duration.zero,
    this.isSavingRemote = false,
    this.selectedBlankId,
    this.selectedPromptId,
    this.errorKey,
    this.errorMessage,
    this.messageKey,
    this.validationErrors = const <String, List<String>>{},
    this.isStarting = false,
    this.isSubmitting = false,
    this.didTimeOut = false,
    this.saveStatus = LessonTestSaveStatus.idle,
    this.result,
    this.resultOnly = false,
  });

  final LessonTestStatus status;
  final LessonTestModel? quiz;
  final QuizAttemptModel? attempt;

  final Map<String, TestAnswerModel> answers;
  final Map<String, List<String>> rightOrder;

  final int currentIndex;
  final Duration remaining;
  final int questionTick;

  final Map<String, QuestionTimerModel> questionTimers;
  final Set<String> openedQuestionIds;
  final Set<String> lockedQuestionIds;
  final String? openingQuestionId;
  final Duration clockOffset;
  final bool isSavingRemote;

  final String? selectedBlankId;
  final String? selectedPromptId;

  final String? errorKey;
  final String? errorMessage;
  final String? messageKey;
  final Map<String, List<String>> validationErrors;

  final bool isStarting;
  final bool isSubmitting;
  final bool didTimeOut;
  final LessonTestSaveStatus saveStatus;
  final QuizAttemptModel? result;
  final bool resultOnly;

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

  DateTime get serverNow => DateTime.now().add(clockOffset);

  QuestionTimerModel? get currentQuestionTimer =>
      questionTimers[currentQuestion?.id];

  Duration? get currentQuestionRemaining {
    final QuestionTimerModel? timer = currentQuestionTimer;
    if (timer == null || !timer.enabled) return null;
    if (timer.hasExpired) return Duration.zero;

    final DateTime? expiresAt = timer.expiresAt;
    if (expiresAt == null) return null;

    final Duration left = expiresAt.difference(serverNow);
    return left.isNegative ? Duration.zero : left;
  }

  bool isQuestionLocked(String questionId) {
    if (lockedQuestionIds.contains(questionId)) return true;

    final QuestionTimerModel? timer = questionTimers[questionId];
    if (timer == null || !timer.enabled) return false;
    if (timer.hasExpired || !timer.canAnswer) return true;

    return !openedQuestionIds.contains(questionId);
  }

  bool get isCurrentQuestionLocked {
    final TestQuestionModel? question = currentQuestion;
    return question != null && isQuestionLocked(question.id);
  }

  bool get isCurrentQuestionExpired {
    final QuestionTimerModel? timer = currentQuestionTimer;
    if (timer == null || !timer.enabled) return false;
    if (timer.hasExpired) return true;
    final Duration? remaining = currentQuestionRemaining;
    return remaining != null && remaining <= Duration.zero;
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
    int? questionTick,
    Map<String, QuestionTimerModel>? questionTimers,
    Set<String>? openedQuestionIds,
    Set<String>? lockedQuestionIds,
    String? openingQuestionId,
    bool clearOpeningQuestion = false,
    Duration? clockOffset,
    bool? isSavingRemote,
    String? selectedBlankId,
    String? selectedPromptId,
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
    String? errorKey,
    String? errorMessage,
    bool clearError = false,
    String? messageKey,
    bool clearMessage = false,
    Map<String, List<String>>? validationErrors,
    bool? isStarting,
    bool? isSubmitting,
    bool? didTimeOut,
    LessonTestSaveStatus? saveStatus,
    QuizAttemptModel? result,
    bool? resultOnly,
  }) => LessonTestState(
    status: status ?? this.status,
    quiz: quiz ?? this.quiz,
    attempt: attempt ?? this.attempt,
    answers: answers ?? this.answers,
    rightOrder: rightOrder ?? this.rightOrder,
    currentIndex: currentIndex ?? this.currentIndex,
    remaining: remaining ?? this.remaining,
    questionTick: questionTick ?? this.questionTick,
    questionTimers: questionTimers ?? this.questionTimers,
    openedQuestionIds: openedQuestionIds ?? this.openedQuestionIds,
    lockedQuestionIds: lockedQuestionIds ?? this.lockedQuestionIds,
    openingQuestionId: clearOpeningQuestion
        ? null
        : openingQuestionId ?? this.openingQuestionId,
    clockOffset: clockOffset ?? this.clockOffset,
    isSavingRemote: isSavingRemote ?? this.isSavingRemote,
    selectedBlankId: clearSelectedBlank
        ? null
        : selectedBlankId ?? this.selectedBlankId,
    selectedPromptId: clearSelectedPrompt
        ? null
        : selectedPromptId ?? this.selectedPromptId,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    messageKey: clearMessage ? null : messageKey ?? this.messageKey,
    validationErrors: clearError
        ? const <String, List<String>>{}
        : validationErrors ?? this.validationErrors,
    isStarting: isStarting ?? this.isStarting,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    didTimeOut: didTimeOut ?? this.didTimeOut,
    saveStatus: saveStatus ?? this.saveStatus,
    result: result ?? this.result,
    resultOnly: resultOnly ?? this.resultOnly,
  );
}
