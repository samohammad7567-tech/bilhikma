part of 'lesson_test_cubit.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension LessonTestAttempt on LessonTestCubit {
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
}
