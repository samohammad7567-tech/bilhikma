part of 'lesson_test_cubit.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

const List<Duration> _remoteSaveBackoff = <Duration>[
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 8),
  Duration(seconds: 16),
  Duration(seconds: 30),
];

extension LessonTestSaves on LessonTestCubit {
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
}
