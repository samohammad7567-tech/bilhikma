part of 'lesson_test_cubit.dart';

enum LessonTestStatus { initial, loading, success, failure }

enum LessonTestPhase { intro, running, result }

final class LessonTestState {
  const LessonTestState({
    this.status = LessonTestStatus.initial,
    this.phase = LessonTestPhase.intro,
    this.test,
    this.answers = const <String, TestAnswerModel>{},
    this.matchOrder = const <String, List<String>>{},
    this.currentIndex = 0,
    this.remaining = Duration.zero,
    this.questionElapsed = Duration.zero,
    this.selectedBlankId,
    this.selectedPromptId,
    this.result,
    this.errorKey,
    this.messageKey,
  });

  final LessonTestStatus status;
  final LessonTestPhase phase;

  final LessonTestModel? test;

  final Map<String, TestAnswerModel> answers;

  final Map<String, List<String>> matchOrder;

  final int currentIndex;

  final Duration remaining;
  final Duration questionElapsed;

  final String? selectedBlankId;

  final String? selectedPromptId;

  final TestResultModel? result;

  final String? errorKey;
  final String? messageKey;

  bool get isLoading =>
      status == LessonTestStatus.loading || status == LessonTestStatus.initial;

  bool get hasFailed => status == LessonTestStatus.failure;

  int get questionCount => test?.questionCount ?? 0;

  TestQuestionModel? get currentQuestion => test?.questionAt(currentIndex);

  TestAnswerModel get currentAnswer =>
      answers[currentQuestion?.id] ?? const TestAnswerModel();

  TestAnswerModel answerOf(String questionId) =>
      answers[questionId] ?? const TestAnswerModel();

  List<String> matchOrderOf(String questionId) =>
      matchOrder[questionId] ?? const <String>[];

  bool get isFirstQuestion => currentIndex == 0;

  bool get isLastQuestion =>
      questionCount == 0 || currentIndex >= questionCount - 1;

  double get progress =>
      questionCount == 0 ? 0 : (currentIndex + 1) / questionCount;

  Duration? get questionRemaining {
    final Duration? limit = currentQuestion?.timeLimit;
    if (limit == null) return null;

    final Duration left = limit - questionElapsed;
    return left.isNegative ? Duration.zero : left;
  }

  LessonTestState copyWith({
    LessonTestStatus? status,
    LessonTestPhase? phase,
    LessonTestModel? test,
    Map<String, TestAnswerModel>? answers,
    Map<String, List<String>>? matchOrder,
    int? currentIndex,
    Duration? remaining,
    Duration? questionElapsed,
    String? selectedBlankId,
    String? selectedPromptId,
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
    TestResultModel? result,
    String? errorKey,
    String? messageKey,
  }) => LessonTestState(
    status: status ?? this.status,
    phase: phase ?? this.phase,
    test: test ?? this.test,
    answers: answers ?? this.answers,
    matchOrder: matchOrder ?? this.matchOrder,
    currentIndex: currentIndex ?? this.currentIndex,
    remaining: remaining ?? this.remaining,
    questionElapsed: questionElapsed ?? this.questionElapsed,
    selectedBlankId: clearSelectedBlank
        ? null
        : selectedBlankId ?? this.selectedBlankId,
    selectedPromptId: clearSelectedPrompt
        ? null
        : selectedPromptId ?? this.selectedPromptId,
    result: result ?? this.result,
    errorKey: errorKey,
    messageKey: messageKey,
  );
}
