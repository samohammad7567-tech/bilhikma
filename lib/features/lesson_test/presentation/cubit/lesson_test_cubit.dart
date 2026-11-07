import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/data_source/lesson_test_local_data_source.dart';
import '../../data/models/lesson_test_model.dart';
import '../../data/models/question_start_model.dart';
import '../../data/models/question_timer_model.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_save_result_model.dart';
import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/quiz_error_mapper.dart';
import '../../data/repos/lesson_test_repo.dart';

part 'lesson_test_state.dart';

class LessonTestCubit extends Cubit<LessonTestState> {
  LessonTestCubit({
    required this.lessonId,
    this.repo = const LessonTestRepo(),
    this.localStore = const LessonTestLocalDataSource(),
    this.resultOnly = false,
    this.initialQuizId,
    this.initialAttemptId,
  }) : super(LessonTestState(resultOnly: resultOnly)) {
    if (resultOnly) {
      unawaited(loadResult(quizId: initialQuizId, attemptId: initialAttemptId));
    } else {
      loadQuiz();
    }
  }

  final int lessonId;
  final LessonTestRepo repo;
  final LessonTestLocalDataSource localStore;
  final bool resultOnly;
  final int? initialQuizId;
  final int? initialAttemptId;

  Timer? _ticker;
  Timer? _cacheTimer;
  Timer? _remoteSaveTimer;
  Timer? _remoteSaveRetryTimer;
  int _remoteSaveAttempts = 0;
  bool _startRequested = false;
  bool _submitRequested = false;
  int _saveRevision = 0;
  final Map<String, Map<String, dynamic>> _pendingRemoteSaves =
      <String, Map<String, dynamic>>{};
  final Set<String> _openingQuestions = <String>{};
  final Set<String> _notifiedLocked = <String>{};
  final Set<String> _saveRetryIds = <String>{};

  static const List<Duration> _remoteSaveBackoff = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  Future<void> retry() async {
    if (state.hasFailed && state.attempt != null) {
      if (state.didTimeOut) {
        await submit(timedOut: true);
        return;
      }

      await _resumeAfterOffline();
      return;
    }

    return state.resultOnly || resultOnly
        ? loadResult(quizId: initialQuizId, attemptId: initialAttemptId)
        : loadQuiz();
  }

  bool _isOffline(AppException exception) =>
      exception.key == ErrorMapper.noInternetKey;

  /// Takes the test off the screen when the API can no longer be reached.
  ///
  /// The attempt and its answers are kept, so [retry] can put the same test
  /// back instead of starting over.
  void _failAndStop(AppException exception) {
    if (isClosed) return;

    _stopTicker();
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = null;
    _cancelRemoteSaveRetry();
    _startRequested = false;
    _submitRequested = false;

    emit(
      state.copyWith(
        status: LessonTestStatus.failure,
        errorKey: exception.key,
        errorMessage: exception.message,
        isStarting: false,
        isSubmitting: false,
        isSavingRemote: false,
        saveStatus: LessonTestSaveStatus.failed,
        clearMessage: true,
      ),
    );
  }

  Future<void> _resumeAfterOffline() async {
    if (state.attempt == null) return;

    emit(
      state.copyWith(
        status: LessonTestStatus.loading,
        saveStatus: LessonTestSaveStatus.idle,
        clearError: true,
        clearMessage: true,
      ),
    );

    try {
      final LessonTestModel quiz = await repo.fetchQuiz(lessonId);
      if (isClosed) return;
      emit(state.copyWith(quiz: quiz));
    } catch (error) {
      if (isClosed) return;
      _failAndStop(QuizErrorMapper.translate(ErrorMapper.toException(error)));
      return;
    }

    emit(
      state.copyWith(
        status: LessonTestStatus.running,
        saveStatus: LessonTestSaveStatus.idle,
        clearError: true,
        clearMessage: true,
      ),
    );

    _startTicker();
    await openQuestion(state.currentIndex);

    if (isClosed || !state.isRunning || _pendingRemoteSaves.isEmpty) return;
    unawaited(_flushRemoteSaves(report: false));
  }

  Future<int> resolveCategorySubjectId() async {
    if (lessonId <= 0) return 0;

    try {
      return await repo.fetchCategorySubjectId(lessonId);
    } catch (_) {
      return 0;
    }
  }

  Future<void> loadQuiz() async {
    _stopTicker();
    _resetRemoteState();
    _startRequested = false;
    _submitRequested = false;

    emit(const LessonTestState(status: LessonTestStatus.loading));

    try {
      final LessonTestModel quiz = await repo.fetchQuiz(lessonId);
      if (isClosed) return;

      emit(LessonTestState(status: LessonTestStatus.ready, quiz: quiz));
    } catch (error) {
      if (isClosed) return;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );

      emit(
        state.copyWith(
          status: LessonTestStatus.failure,
          errorKey: exception.key,
          errorMessage: exception.message,
        ),
      );
    }
  }

  Future<void> loadResult({int? quizId, int? attemptId}) async {
    _stopTicker();
    _resetRemoteState();
    _startRequested = false;
    _submitRequested = false;

    emit(
      const LessonTestState(status: LessonTestStatus.loading, resultOnly: true),
    );

    LessonTestModel? quiz;
    AppException? quizFailure;
    try {
      quiz = await repo.fetchQuiz(lessonId);
    } catch (error) {
      quizFailure = QuizErrorMapper.translate(ErrorMapper.toException(error));
      quiz = null;
    }
    if (isClosed) return;

    QuizAttemptModel? target;
    final int? requestedAttemptId = attemptId ?? initialAttemptId;

    if (requestedAttemptId != null && requestedAttemptId > 0) {
      target = await _fetchSubmittedAttempt(requestedAttemptId);
      if (isClosed) return;
    }

    if (target == null) {
      final int? resolvedQuizId = quizId ?? quiz?.id;
      if (resolvedQuizId == null) {
        _emitResultFailure(
          quizFailure ?? const AppException(LangKeys.quizResultUnavailable),
        );
        return;
      }

      try {
        final List<QuizAttemptModel> attempts = await repo.fetchMyAttempts(
          resolvedQuizId,
        );
        if (isClosed) return;

        final List<QuizAttemptModel> submitted =
            attempts
                .where((QuizAttemptModel attempt) => attempt.isSubmitted)
                .toList()
              ..sort(_latestAttemptFirst);

        QuizAttemptModel? selected;
        if (requestedAttemptId != null) {
          for (final QuizAttemptModel attempt in submitted) {
            if (attempt.id == requestedAttemptId) {
              selected = attempt;
              break;
            }
          }
        }
        selected ??= submitted.isEmpty ? null : submitted.first;

        if (selected != null) {
          target = await _fetchSubmittedAttempt(selected.id) ?? selected;
          if (isClosed) return;
        }
      } catch (error) {
        if (isClosed) return;

        final AppException exception = QuizErrorMapper.translate(
          ErrorMapper.toException(error),
        );
        _emitResultFailure(exception);
        return;
      }
    }

    if (target == null) {
      _emitResultFailure(const AppException(LangKeys.quizResultUnavailable));
      return;
    }

    emit(
      LessonTestState(
        status: LessonTestStatus.result,
        quiz: quiz,
        attempt: target,
        result: target,
        remaining: Duration.zero,
        resultOnly: true,
      ),
    );
  }

  /// Loads the full attempt after submission so the result can show the
  /// questions and the released solutions without starting a new attempt.
  Future<QuizAttemptModel?> _fetchSubmittedAttempt(int attemptId) async {
    try {
      final QuizAttemptModel attempt = await repo.fetchAttempt(attemptId);
      return attempt.isSubmitted ? attempt : null;
    } catch (_) {
      return null;
    }
  }

  int _latestAttemptFirst(QuizAttemptModel a, QuizAttemptModel b) {
    final DateTime? aDate = a.submittedAt;
    final DateTime? bDate = b.submittedAt;
    if (aDate != null && bDate != null) return bDate.compareTo(aDate);
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    return b.id.compareTo(a.id);
  }

  void _emitResultFailure(AppException exception) {
    emit(
      LessonTestState(
        status: LessonTestStatus.failure,
        errorKey: exception.key,
        errorMessage: exception.message,
        resultOnly: true,
      ),
    );
  }

  Future<void> startAttempt() async {
    final LessonTestModel? quiz = state.quiz;

    if (_startRequested || state.isStarting || quiz == null) {
      return;
    }

    if (!quiz.isSupported) {
      reportMessage(LangKeys.assessmentUnsupportedMessage);
      return;
    }

    if (!state.canStart) return;

    _startRequested = true;
    _resetRemoteState();

    emit(
      state.copyWith(
        status: LessonTestStatus.starting,
        isStarting: true,
        clearError: true,
        clearMessage: true,
      ),
    );

    try {
      final QuizAttemptModel attempt = await repo.startAttempt(quiz.id);
      if (isClosed) return;

      if (attempt.isSubmitted) {
        _emitResult(attempt);
        return;
      }

      if (attempt.questions.isEmpty) {
        emit(
          state.copyWith(
            status: LessonTestStatus.ready,
            errorKey: LangKeys.quizUnavailable,
            messageKey: LangKeys.quizUnavailable,
            isStarting: false,
          ),
        );
        return;
      }

      final Duration offset = attempt.serverNow == null
          ? Duration.zero
          : attempt.serverNow!.difference(DateTime.now());
      final Map<String, QuestionTimerModel> timers = attempt.questionTimers;
      final Set<String> opened = <String>{
        for (final MapEntry<String, QuestionTimerModel> entry in timers.entries)
          if (entry.value.startedAt != null) entry.key,
      };
      final Set<String> locked = <String>{
        for (final MapEntry<String, QuestionTimerModel> entry in timers.entries)
          if (entry.value.enabled && entry.value.hasExpired) entry.key,
      };

      final Map<String, TestAnswerModel> restored = _restoredAnswers(attempt);
      final int startIndex = _resumeIndex(attempt, restored);

      emit(
        state.copyWith(
          status: LessonTestStatus.running,
          attempt: attempt,
          answers: restored,
          rightOrder: _initialRightOrder(attempt),
          currentIndex: startIndex,
          remaining: _remainingOf(attempt, offset),
          questionTick: 0,
          questionTimers: timers,
          openedQuestionIds: opened,
          lockedQuestionIds: locked,
          clockOffset: offset,
          isStarting: false,
          didTimeOut: false,
          clearSelectedBlank: true,
          clearSelectedPrompt: true,
          clearError: true,
          clearMessage: true,
        ),
      );

      _startTicker();
      unawaited(openQuestion(startIndex));
    } catch (error) {
      if (isClosed) return;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );

      if (_isOffline(exception)) {
        _failAndStop(exception);
        return;
      }

      emit(
        state.copyWith(
          status: LessonTestStatus.ready,
          errorKey: exception.key,
          errorMessage: exception.message,
          messageKey: exception.key,
          isStarting: false,
        ),
      );
    } finally {
      _startRequested = false;
    }
  }

  Future<void> reopenCurrentQuestion() async {
    if (!state.isRunning) return;
    await openQuestion(state.currentIndex);
  }

  Future<void> openQuestion(int index) async {
    if (!state.isRunning || state.isSubmitting) return;

    final QuizAttemptModel? attempt = state.attempt;
    final List<TestQuestionModel> questions =
        attempt?.questions ?? const <TestQuestionModel>[];
    if (attempt == null || index < 0 || index >= questions.length) return;

    final TestQuestionModel question = questions[index];

    if (!attempt.questionTimingEnabled) {
      if (!state.openedQuestionIds.contains(question.id)) {
        emit(
          state.copyWith(
            openedQuestionIds: <String>{
              ...state.openedQuestionIds,
              question.id,
            },
          ),
        );
      }
      return;
    }

    if (_openingQuestions.contains(question.id)) return;

    _openingQuestions.add(question.id);
    emit(state.copyWith(openingQuestionId: question.id));

    try {
      final QuestionStartModel result = await repo.startQuestion(
        attempt.id,
        question.id,
      );
      if (isClosed) return;
      _applyQuestionStart(question, result);
    } on FormatException {
      _handleOpenFailure(
        question,
        const AppException(LangKeys.quizQuestionOpenFailed),
      );
    } catch (error) {
      if (isClosed) return;
      _handleOpenFailure(
        question,
        QuizErrorMapper.translate(ErrorMapper.toException(error)),
      );
    } finally {
      _openingQuestions.remove(question.id);
      if (!isClosed && state.openingQuestionId == question.id) {
        emit(state.copyWith(clearOpeningQuestion: true));
      }
    }
  }

  void _applyQuestionStart(
    TestQuestionModel question,
    QuestionStartModel result,
  ) {
    final Duration offset = result.serverNow.difference(DateTime.now());
    final Map<String, QuestionTimerModel> timers =
        Map<String, QuestionTimerModel>.of(state.questionTimers)
          ..[question.id] = result.timer;

    final Set<String> opened = <String>{
      ...state.openedQuestionIds,
      question.id,
    };
    final Set<String> locked = <String>{...state.lockedQuestionIds};

    final bool expired =
        result.timer.enabled &&
        (result.timer.hasExpired ||
            (!result.timer.canAnswer && result.timer.startedAt != null));
    if (expired) {
      locked.add(question.id);
    } else if (!result.timer.enabled || result.timer.canAnswer) {
      locked.remove(question.id);
    }

    QuizAttemptModel attempt = state.attempt!;
    final DateTime? attemptExpires =
        result.attemptExpiresAt ?? attempt.expiresAt;
    if (attemptExpires != attempt.expiresAt) {
      attempt = attempt.copyWith(expiresAt: attemptExpires);
    }

    Map<String, TestAnswerModel> answers = state.answers;
    final Map<String, dynamic>? saved = result.savedAnswer;
    if (saved != null) {
      final TestAnswerModel remote = TestAnswerModel.fromSavedJson(saved);
      if (_isValidRestoredOrder(question, remote)) {
        final TestAnswerModel? local = state.answers[question.id];
        final bool lockedNow = locked.contains(question.id);
        if (local == null || !local.isTouched || lockedNow) {
          answers = Map<String, TestAnswerModel>.of(state.answers)
            ..[question.id] = remote;
        } else {
          _queueRemoteSaveIfDiffers(question, local, saved);
        }
      }
    }

    final bool lockedNow = locked.contains(question.id);
    final String? lockMessage =
        lockedNow && state.currentQuestion?.id == question.id
        ? LangKeys.quizQuestionTimeUp
        : null;

    emit(
      state.copyWith(
        attempt: attempt,
        answers: answers,
        questionTimers: timers,
        openedQuestionIds: opened,
        lockedQuestionIds: locked,
        clockOffset: offset,
        remaining: _remainingOf(attempt, offset),
        messageKey: lockMessage,
      ),
    );
  }

  void _handleOpenFailure(TestQuestionModel question, AppException exception) {
    if (isClosed) return;

    if (_isOffline(exception)) {
      _failAndStop(exception);
      return;
    }

    if (exception.statusCode == 401) {
      emit(
        state.copyWith(
          errorKey: exception.key,
          messageKey: exception.key,
          clearOpeningQuestion: true,
        ),
      );
      return;
    }

    if (_isAlreadySubmitted(exception)) {
      unawaited(_recoverSubmittedAttempt());
      return;
    }

    if (exception.key == LangKeys.quizQuestionTimeUp) {
      final Map<String, QuestionTimerModel> timers =
          Map<String, QuestionTimerModel>.of(state.questionTimers);
      final QuestionTimerModel? timer = timers[question.id];
      if (timer != null) {
        timers[question.id] = timer.copyWith(
          hasExpired: true,
          canAnswer: false,
        );
      }
      emit(
        state.copyWith(
          questionTimers: timers,
          lockedQuestionIds: <String>{...state.lockedQuestionIds, question.id},
          messageKey: LangKeys.quizQuestionTimeUp,
        ),
      );
      return;
    }

    if (exception.key == LangKeys.quizTimeUp) {
      emit(state.copyWith(didTimeOut: true, remaining: Duration.zero));
      unawaited(submit(timedOut: true));
      return;
    }

    emit(
      state.copyWith(
        errorKey: LangKeys.quizQuestionOpenFailed,
        messageKey: LangKeys.quizQuestionOpenFailed,
      ),
    );
  }

  void selectOption(String optionId) {
    if (!state.isRunning) return;

    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    final TestAnswerModel current = state.currentAnswer;

    if (!question.type.isMultiSelect) {
      _emitAnswer(current.copyWith(optionIds: <String>[optionId]));
      return;
    }

    final List<String> picked = List<String>.of(current.optionIds);

    if (picked.contains(optionId)) {
      picked.remove(optionId);
    } else {
      if (picked.length >= question.effectiveMaxSelections) {
        reportMessage(LangKeys.quizMaxSelectionsReached);
        return;
      }
      picked.add(optionId);
    }

    _emitAnswer(current.copyWith(optionIds: picked));
  }

  void selectBoolean(bool value) {
    if (!state.isRunning) return;

    final TestQuestionModel? question = state.currentQuestion;
    if (question == null || !question.type.isTrueFalse) return;

    _emitAnswer(state.currentAnswer.copyWith(boolean: value));
  }

  void selectBlank(String blankId) {
    if (state.isCurrentQuestionLocked) return;

    state.selectedBlankId == blankId
        ? emit(state.copyWith(clearSelectedBlank: true))
        : emit(state.copyWith(selectedBlankId: blankId));
  }

  void assignWord(String optionId) {
    if (!state.isRunning) return;

    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    final TestAnswerModel current = state.currentAnswer;
    final String? target = state.selectedBlankId ?? _firstEmptyBlank(question);
    if (target == null) return;

    final Map<String, String> blanks = Map<String, String>.of(current.blanks)
      ..[target] = optionId;

    if (!(question.optionById(optionId)?.isReusable ?? false)) {
      blanks.removeWhere(
        (String blankId, String value) =>
            value == optionId && blankId != target,
      );
    }

    _emitAnswer(current.copyWith(blanks: blanks), clearSelectedBlank: true);
  }

  void selectBlankChoice({required String blankId, required String optionId}) {
    if (!state.isRunning) return;

    final TestAnswerModel current = state.currentAnswer;

    final Map<String, String> blanks = Map<String, String>.of(current.blanks)
      ..[blankId] = optionId;

    if (!(state.currentQuestion?.optionById(optionId)?.isReusable ?? false)) {
      blanks.removeWhere(
        (String id, String value) => value == optionId && id != blankId,
      );
    }

    _emitAnswer(current.copyWith(blanks: blanks), clearSelectedBlank: true);
  }

  void clearBlank(String blankId) {
    if (!state.isRunning) return;

    final TestAnswerModel current = state.currentAnswer;
    if (!current.blanks.containsKey(blankId)) return;

    _emitAnswer(
      current.copyWith(
        blanks: Map<String, String>.of(current.blanks)..remove(blankId),
      ),
      clearSelectedBlank: true,
    );
  }

  void typeBlank({required String blankId, required String value}) {
    if (!state.isRunning) return;

    final TestAnswerModel current = state.currentAnswer;
    final Map<String, String> blanks = Map<String, String>.of(current.blanks);

    value.trim().isEmpty ? blanks.remove(blankId) : blanks[blankId] = value;

    _emitAnswer(current.copyWith(blanks: blanks));
  }

  void selectPrompt(String leftItemId) {
    if (state.isCurrentQuestionLocked) return;

    state.selectedPromptId == leftItemId
        ? emit(state.copyWith(clearSelectedPrompt: true))
        : emit(state.copyWith(selectedPromptId: leftItemId));
  }

  void linkMatch(String rightItemId) {
    if (!state.isRunning) return;

    final String? leftItemId = state.selectedPromptId;
    if (leftItemId == null) return;

    final TestAnswerModel current = state.currentAnswer;
    final bool allowMany =
        state.currentQuestion?.allowsOneToManyMatching ?? false;

    final Map<String, String> matches = Map<String, String>.of(current.matches);

    if (!allowMany) {
      matches.removeWhere(
        (String rightId, String leftId) => leftId == leftItemId,
      );
    }

    matches[rightItemId] = leftItemId;

    _emitAnswer(
      current.copyWith(matches: matches),
      clearSelectedPrompt: !allowMany,
    );
  }

  void clearPair(String rightItemId) {
    if (!state.isRunning) return;

    final TestAnswerModel current = state.currentAnswer;
    if (!current.matches.containsKey(rightItemId)) return;

    _emitAnswer(
      current.copyWith(
        matches: Map<String, String>.of(current.matches)..remove(rightItemId),
      ),
      clearSelectedPrompt: true,
    );
  }

  void reorderSentences(int oldIndex, int newIndex) {
    if (!state.isRunning) return;

    final TestAnswerModel current = state.currentAnswer;
    final List<String> order = List<String>.of(current.order);
    if (oldIndex < 0 || oldIndex >= order.length) return;

    final String moved = order.removeAt(oldIndex);
    order.insert(newIndex.clamp(0, order.length), moved);

    _emitAnswer(current.copyWith(order: order));
  }

  void goNext() {
    if (!state.isRunning || state.isSubmitting) return;

    if (state.isLastQuestion) {
      unawaited(submit());
      return;
    }

    _moveTo(state.currentIndex + 1);
  }

  void goPrevious() {
    if (!state.isRunning || state.isSubmitting || state.isFirstQuestion) return;
    _moveTo(state.currentIndex - 1);
  }

  Future<bool> submit({bool timedOut = false}) async {
    if (_submitRequested ||
        state.isSubmitting ||
        state.status == LessonTestStatus.submitting ||
        state.status == LessonTestStatus.result) {
      return false;
    }

    final QuizAttemptModel? attempt = state.attempt;
    if (attempt == null) return false;

    _submitRequested = true;

    if (_pendingRemoteSaves.isNotEmpty) {
      await _flushRemoteSaves(report: false);
      if (isClosed) return false;
      if (state.isResult) return true;
      if (state.hasFailed) return false;
    }

    _cancelRemoteSaveRetry();
    _stopTicker();

    emit(
      state.copyWith(
        status: LessonTestStatus.submitting,
        isSubmitting: true,
        clearError: true,
        clearMessage: true,
      ),
    );

    final Map<String, Map<String, dynamic>> payload =
        <String, Map<String, dynamic>>{};

    try {
      for (final TestQuestionModel question in attempt.questions) {
        final TestAnswerModel answer = state.answerOf(question.id);

        if (question.type.isOrdering && !answer.isTouched) {
          continue;
        }

        if (!answer.isAnswered(question.type)) {
          continue;
        }

        payload[question.id] = answer.toSubmissionJson(question);
      }
    } on AnswerValidationException catch (error) {
      _emitSubmitFailure(
        const AppException(LangKeys.quizAnswersInvalid),
        validationErrors: <String, List<String>>{
          'answers': <String>[error.key],
        },
        restartTicker: true,
      );
      return false;
    } on FormatException {
      _emitSubmitFailure(
        const AppException(LangKeys.quizAnswersInvalid),
        restartTicker: true,
      );
      return false;
    } catch (_) {
      _emitSubmitFailure(
        const AppException(LangKeys.quizAnswersInvalid),
        restartTicker: true,
      );
      return false;
    }

    try {
      final QuizAttemptModel result = await repo.submitAttempt(
        attempt.id,
        payload,
      );
      if (isClosed) return false;

      _submitRequested = true;
      _emitResult(result, timedOut: timedOut);
      return true;
    } catch (error) {
      if (isClosed) return false;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );

      if (_isOffline(exception)) {
        _failAndStop(exception);
        return false;
      }

      if (exception.statusCode == 401) {
        _submitRequested = false;
        emit(
          state.copyWith(
            status: LessonTestStatus.running,
            errorKey: exception.key,
            messageKey: exception.key,
            isSubmitting: false,
          ),
        );
        return false;
      }

      if (_isAlreadySubmitted(exception)) {
        final bool recovered = await _recoverSubmittedAttempt();
        if (recovered) return true;
        if (isClosed) return false;
      }

      final bool restartTicker = exception.statusCode != 401;

      _emitSubmitFailure(
        exception,
        validationErrors: exception.statusCode == 422
            ? exception.errors
            : const <String, List<String>>{},
        restartTicker: restartTicker,
      );
      return false;
    }
  }

  Future<bool> submitAndLeave() async {
    if (!state.isRunning || state.isSubmitting) return false;

    return submit();
  }

  Future<bool> flushAndLeave() async {
    if (!state.isRunning || state.isSubmitting) return false;
    await flushAnswers();
    return true;
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));

  Future<void> flushAnswers() async {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    await _persistAnswers();
    await _flushRemoteSaves(report: false);
  }

  @override
  Future<void> close() async {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = null;
    await _persistAnswers(report: false);
    await _flushRemoteSaves(report: false);
    _cancelRemoteSaveRetry();
    _stopTicker();
    return super.close();
  }

  void _tick() {
    if (state.status != LessonTestStatus.running || state.didTimeOut) return;

    final DateTime? expiresAt = state.attempt?.expiresAt;
    final DateTime now = state.serverNow;
    final String? currentQuestionId = state.currentQuestion?.id;

    Map<String, QuestionTimerModel> timers = state.questionTimers;
    Set<String> locked = state.lockedQuestionIds;
    bool timersChanged = false;
    String? lockMessage;

    if (timers.isNotEmpty) {
      final Map<String, QuestionTimerModel> updated =
          Map<String, QuestionTimerModel>.of(timers);
      final Set<String> updatedLocked = <String>{...locked};

      for (final MapEntry<String, QuestionTimerModel> entry in timers.entries) {
        final QuestionTimerModel timer = entry.value;
        if (!timer.enabled || timer.hasExpired) continue;

        final DateTime? questionExpiresAt = timer.expiresAt;
        if (questionExpiresAt == null || questionExpiresAt.isAfter(now)) {
          continue;
        }

        updated[entry.key] = timer.copyWith(hasExpired: true, canAnswer: false);
        updatedLocked.add(entry.key);
        timersChanged = true;

        if (entry.key == currentQuestionId && _notifiedLocked.add(entry.key)) {
          lockMessage = LangKeys.quizQuestionTimeUp;
        }
      }

      if (timersChanged) {
        timers = updated;
        locked = updatedLocked;
      }
    }

    final Duration? remaining = expiresAt?.difference(now);

    if (remaining != null && remaining <= Duration.zero) {
      emit(
        state.copyWith(
          remaining: Duration.zero,
          didTimeOut: true,
          questionTimers: timers,
          lockedQuestionIds: locked,
        ),
      );
      unawaited(submit(timedOut: true));
      return;
    }

    if (remaining == null && !timersChanged && timers.isEmpty) return;

    emit(
      state.copyWith(
        remaining: remaining ?? state.remaining,
        questionTick: state.questionTick + 1,
        questionTimers: timers,
        lockedQuestionIds: locked,
        messageKey: lockMessage,
      ),
    );
  }

  void _moveTo(int index) {
    emit(
      state.copyWith(
        currentIndex: index,
        questionTick: 0,
        clearSelectedBlank: true,
        clearSelectedPrompt: true,
      ),
    );

    _startTicker();
    unawaited(openQuestion(index));
  }

  void _emitAnswer(
    TestAnswerModel answer, {
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
  }) {
    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;
    if (state.isQuestionLocked(question.id)) return;

    final TestAnswerModel touched = answer.copyWith(isTouched: true);

    _cancelRemoteSaveRetry();
    _saveRevision++;

    emit(
      state.copyWith(
        answers: Map<String, TestAnswerModel>.of(state.answers)
          ..[question.id] = touched,
        saveStatus: LessonTestSaveStatus.saving,
        clearSelectedBlank: clearSelectedBlank,
        clearSelectedPrompt: clearSelectedPrompt,
      ),
    );

    _schedulePersist();
    _queueRemoteSave(question, touched);
  }

  void _emitResult(QuizAttemptModel result, {bool timedOut = false}) {
    _stopTicker();
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = null;
    _cancelRemoteSaveRetry();
    _pendingRemoteSaves.clear();
    _notifiedLocked.clear();
    _saveRetryIds.clear();
    localStore.clear(result.id);

    emit(
      state.copyWith(
        status: LessonTestStatus.result,
        result: result,
        remaining: Duration.zero,
        isStarting: false,
        isSubmitting: false,
        saveStatus: LessonTestSaveStatus.idle,
        messageKey: timedOut ? LangKeys.quizTimeUp : null,
        clearError: true,
        validationErrors: const <String, List<String>>{},
      ),
    );
  }

  void _emitSubmitFailure(
    AppException exception, {
    Map<String, List<String>> validationErrors = const <String, List<String>>{},
    required bool restartTicker,
  }) {
    if (isClosed) return;

    _submitRequested = false;

    emit(
      state.copyWith(
        status: LessonTestStatus.running,
        errorKey: exception.key,
        messageKey: exception.key,
        validationErrors: validationErrors,
        isSubmitting: false,
      ),
    );

    if (restartTicker && !state.didTimeOut) _startTicker();
  }

  Future<bool> _recoverSubmittedAttempt() async {
    final int? quizId = state.quiz?.id;
    final int? attemptId = state.attempt?.id;
    if (quizId == null || attemptId == null) return false;

    try {
      final List<QuizAttemptModel> attempts = await repo.fetchMyAttempts(
        quizId,
      );
      if (isClosed) return false;

      for (final QuizAttemptModel attempt in attempts) {
        if (attempt.id == attemptId && attempt.isSubmitted) {
          _submitRequested = true;
          _emitResult(attempt);
          return true;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  void _startTicker() {
    _stopTicker();
    if (state.attempt == null) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _schedulePersist() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_persistAnswers()),
    );
  }

  void _resetRemoteState() {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = null;
    _cancelRemoteSaveRetry();
    _pendingRemoteSaves.clear();
    _openingQuestions.clear();
    _notifiedLocked.clear();
    _saveRetryIds.clear();
  }

  void _queueRemoteSaveIfDiffers(
    TestQuestionModel question,
    TestAnswerModel answer,
    Map<String, dynamic> saved,
  ) {
    if (!state.isRunning || state.attempt == null) return;

    Map<String, dynamic> local;
    try {
      local = answer.toSubmissionJson(question);
    } on AnswerValidationException {
      return;
    } on FormatException {
      return;
    }

    if (_sameJson(local, saved)) return;

    _queueRemoteSave(question, answer);
  }

  bool _sameJson(Object? a, Object? b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final Object? key in a.keys) {
        if (!b.containsKey(key) || !_sameJson(a[key], b[key])) return false;
      }
      return true;
    }

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_sameJson(a[i], b[i])) return false;
      }
      return true;
    }

    return a == b;
  }

  void _queueRemoteSave(TestQuestionModel question, TestAnswerModel answer) {
    if (!state.isRunning || state.attempt == null) return;

    try {
      _pendingRemoteSaves[question.id] = answer.toSubmissionJson(question);
    } on AnswerValidationException {
      return;
    } on FormatException {
      return;
    }

    _scheduleRemoteSave();
  }

  void _scheduleRemoteSave() {
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = Timer(
      const Duration(milliseconds: 1200),
      () => unawaited(_flushRemoteSaves()),
    );
  }

  void _cancelRemoteSaveRetry() {
    _remoteSaveRetryTimer?.cancel();
    _remoteSaveRetryTimer = null;
    _remoteSaveAttempts = 0;
  }

  void _scheduleRemoteSaveRetry() {
    if (isClosed || _remoteSaveRetryTimer != null) return;

    final QuizAttemptModel? attempt = state.attempt;
    if (attempt == null ||
        _pendingRemoteSaves.isEmpty ||
        state.isResult ||
        state.resultOnly ||
        !state.isRunning ||
        attempt.hasExpired) {
      return;
    }

    final int index = _remoteSaveAttempts < _remoteSaveBackoff.length
        ? _remoteSaveAttempts
        : _remoteSaveBackoff.length - 1;
    final Duration delay = _remoteSaveBackoff[index];
    _remoteSaveAttempts++;

    _remoteSaveRetryTimer = Timer(delay, () {
      _remoteSaveRetryTimer = null;
      unawaited(_flushRemoteSaves());
    });
  }

  Future<void> _flushRemoteSaves({bool report = true}) async {
    _remoteSaveTimer?.cancel();
    _remoteSaveTimer = null;
    _remoteSaveRetryTimer?.cancel();
    _remoteSaveRetryTimer = null;

    final QuizAttemptModel? attempt = state.attempt;
    if (attempt == null || _pendingRemoteSaves.isEmpty) return;
    if (state.isResult || state.resultOnly || !state.isRunning) return;

    final Map<String, Map<String, dynamic>> payload =
        Map<String, Map<String, dynamic>>.of(_pendingRemoteSaves);

    if (report && !isClosed) {
      emit(
        state.copyWith(
          isSavingRemote: true,
          saveStatus: LessonTestSaveStatus.saving,
        ),
      );
    }

    try {
      final QuizSaveResultModel result = await repo.saveAnswers(
        attempt.id,
        payload,
      );
      if (isClosed) return;

      final Duration offset = result.serverNow.difference(DateTime.now());
      final Map<String, QuestionTimerModel> timers =
          Map<String, QuestionTimerModel>.of(state.questionTimers);
      final Set<String> locked = <String>{...state.lockedQuestionIds};

      for (final String id in result.ignoredQuestionIds) {
        _pendingRemoteSaves.remove(id);
        locked.add(id);
        final QuestionTimerModel? timer = timers[id];
        if (timer != null) {
          timers[id] = timer.copyWith(canAnswer: false, hasExpired: true);
        }
      }

      for (final MapEntry<String, Map<String, dynamic>> entry
          in payload.entries) {
        if (_pendingRemoteSaves[entry.key] == entry.value) {
          _pendingRemoteSaves.remove(entry.key);
        }
        _saveRetryIds.remove(entry.key);
      }

      QuizAttemptModel updated = attempt.copyWith(serverNow: result.serverNow);
      if (result.expiresAt != null) {
        updated = updated.copyWith(expiresAt: result.expiresAt);
      }

      _cancelRemoteSaveRetry();

      emit(
        state.copyWith(
          attempt: updated,
          questionTimers: timers,
          lockedQuestionIds: locked,
          clockOffset: offset,
          remaining: _remainingOf(updated, offset),
          isSavingRemote: false,
          saveStatus: LessonTestSaveStatus.saved,
        ),
      );

      if (result.hasExpired || updated.hasExpired) {
        emit(state.copyWith(didTimeOut: true, remaining: Duration.zero));
        unawaited(submit(timedOut: true));
      }
    } catch (error) {
      if (isClosed) return;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );

      if (_isOffline(exception)) {
        if (!isClosed) {
          emit(
            state.copyWith(
              isSavingRemote: false,
              saveStatus: LessonTestSaveStatus.failed,
            ),
          );
          _scheduleRemoteSaveRetry();
        }
        return;
      }

      if (exception.statusCode == 401) {
        emit(
          state.copyWith(
            errorKey: exception.key,
            messageKey: exception.key,
            isSavingRemote: false,
            saveStatus: LessonTestSaveStatus.failed,
          ),
        );
        return;
      }

      if (_isAlreadySubmitted(exception)) {
        _pendingRemoteSaves.clear();
        unawaited(_recoverSubmittedAttempt());
        return;
      }

      if (exception.key == LangKeys.quizQuestionTimeUp) {
        final Map<String, QuestionTimerModel> timers =
            Map<String, QuestionTimerModel>.of(state.questionTimers);
        final Set<String> locked = <String>{...state.lockedQuestionIds};

        for (final String id in payload.keys) {
          _pendingRemoteSaves.remove(id);
          locked.add(id);
          final QuestionTimerModel? timer = timers[id];
          if (timer != null) {
            timers[id] = timer.copyWith(canAnswer: false, hasExpired: true);
          }
        }

        emit(
          state.copyWith(
            questionTimers: timers,
            lockedQuestionIds: locked,
            isSavingRemote: false,
            saveStatus: LessonTestSaveStatus.failed,
            messageKey: LangKeys.quizQuestionTimeUp,
          ),
        );
        return;
      }

      if (exception.key == LangKeys.quizQuestionNotOpened) {
        for (final String id in payload.keys) {
          if (_saveRetryIds.add(id)) {
            unawaited(_openQuestionById(id));
          } else {
            _pendingRemoteSaves.remove(id);
          }
        }
        emit(
          state.copyWith(
            isSavingRemote: false,
            saveStatus: LessonTestSaveStatus.failed,
          ),
        );
        return;
      }

      if (exception.key == LangKeys.quizTimeUp) {
        _pendingRemoteSaves.clear();
        emit(
          state.copyWith(
            isSavingRemote: false,
            saveStatus: LessonTestSaveStatus.failed,
            didTimeOut: true,
            remaining: Duration.zero,
          ),
        );
        unawaited(submit(timedOut: true));
        return;
      }

      emit(
        state.copyWith(
          isSavingRemote: false,
          saveStatus: LessonTestSaveStatus.failed,
        ),
      );
    }
  }

  Future<void> _openQuestionById(String questionId) async {
    final List<TestQuestionModel> questions =
        state.attempt?.questions ?? const <TestQuestionModel>[];
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].id == questionId) {
        await openQuestion(i);
        if (!isClosed && _pendingRemoteSaves.containsKey(questionId)) {
          _scheduleRemoteSave();
        }
        return;
      }
    }
  }

  Future<void> _persistAnswers({bool report = true}) async {
    final QuizAttemptModel? attempt = state.attempt;
    if (attempt == null || state.isResult || state.resultOnly) return;

    final int revision = _saveRevision;

    try {
      await localStore.write(
        LessonTestSavedAnswersModel(
          attemptId: attempt.id,
          quizId: attempt.quizId,
          updatedAt: DateTime.now(),
          answers: state.answers,
        ),
      );
      _reportSave(LessonTestSaveStatus.saved, revision, report: report);
    } catch (_) {
      _reportSave(LessonTestSaveStatus.failed, revision, report: report);
    }
  }

  void _reportSave(
    LessonTestSaveStatus status,
    int revision, {
    required bool report,
  }) {
    if (!report || isClosed || revision != _saveRevision) return;
    emit(state.copyWith(saveStatus: status));
  }

  Duration _remainingOf(QuizAttemptModel attempt, Duration offset) {
    final DateTime? expiresAt = attempt.expiresAt;
    if (expiresAt == null) return Duration.zero;

    final Duration remaining = expiresAt.difference(DateTime.now().add(offset));
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int _resumeIndex(
    QuizAttemptModel attempt,
    Map<String, TestAnswerModel> answers,
  ) {
    final List<TestQuestionModel> questions = attempt.questions;
    if (questions.isEmpty) return 0;

    int lastAnswered = 0;

    for (int index = 0; index < questions.length; index++) {
      final TestQuestionModel question = questions[index];
      final TestAnswerModel? answer = answers[question.id];
      final bool untouchedOrdering =
          question.type == TestQuestionType.orderSentences &&
          !(answer?.isTouched ?? false);
      final bool answered =
          answer != null &&
          answer.isAnswered(question.type) &&
          !untouchedOrdering;

      if (!answered) return index;
      lastAnswered = index;
    }

    return lastAnswered;
  }

  Map<String, TestAnswerModel> _initialAnswers(QuizAttemptModel attempt) {
    final Map<String, TestAnswerModel> answers = <String, TestAnswerModel>{};

    for (final TestQuestionModel question in attempt.questions) {
      if (question.type.isOrdering) {
        answers[question.id] = TestAnswerModel(
          order: question.sentences
              .map((sentence) => sentence.id)
              .toList(growable: false),
        );
      }
    }

    return answers;
  }

  Map<String, TestAnswerModel> _restoredAnswers(QuizAttemptModel attempt) {
    final Map<String, TestAnswerModel> answers = _initialAnswers(attempt);
    final Map<String, TestQuestionModel> questions =
        <String, TestQuestionModel>{
          for (final TestQuestionModel question in attempt.questions)
            question.id: question,
        };

    for (final MapEntry<String, Map<String, dynamic>> entry
        in attempt.savedAnswers.entries) {
      final TestQuestionModel? question = questions[entry.key];
      if (question == null) continue;

      final TestAnswerModel answer = TestAnswerModel.fromSavedJson(entry.value);
      if (!_isValidRestoredOrder(question, answer)) continue;

      answers[entry.key] = answer;
    }

    // The server payload is applied first; the local cache only overlays the
    // same attempt so an edit made between autosaves is not lost.
    final LessonTestSavedAnswersModel? cached = localStore.read(attempt.id);
    if (cached != null && cached.quizId == attempt.quizId) {
      for (final MapEntry<String, TestAnswerModel> entry
          in cached.answers.entries) {
        final TestQuestionModel? question = questions[entry.key];
        if (question == null) continue;
        if (!_isValidRestoredOrder(question, entry.value)) continue;

        answers[entry.key] = entry.value;
      }
    }

    return answers;
  }

  bool _isValidRestoredOrder(
    TestQuestionModel question,
    TestAnswerModel answer,
  ) {
    if (question.type != TestQuestionType.orderSentences) return true;
    if (answer.order.length != question.sentences.length) return false;

    final Set<String> ids = question.sentences
        .map((sentence) => sentence.id)
        .toSet();

    return answer.order.every(ids.contains) &&
        answer.order.toSet().length == answer.order.length;
  }

  Map<String, List<String>> _initialRightOrder(QuizAttemptModel attempt) {
    final Map<String, List<String>> order = <String, List<String>>{};

    for (final TestQuestionModel question in attempt.questions) {
      if (question.type == TestQuestionType.matchPairs) {
        order[question.id] = question.rightItems
            .map((item) => item.id)
            .toList(growable: false);
      }
    }

    return order;
  }

  String? _firstEmptyBlank(TestQuestionModel question) {
    final TestAnswerModel current = state.currentAnswer;

    for (final blank in question.blanks) {
      if (!current.blanks.containsKey(blank.id)) return blank.id;
    }
    return null;
  }

  bool _isAlreadySubmitted(AppException exception) {
    if (exception.statusCode == 409) return true;
    if (exception.key == LangKeys.quizAlreadySubmitted) return true;

    final String text =
        '${exception.message ?? ''} '
                '${exception.errors.values.expand((List<String> e) => e).join(' ')}'
            .toLowerCase();

    return text.contains('already') && text.contains('submit');
  }
}
