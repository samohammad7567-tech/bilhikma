part of 'lesson_test_cubit.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension LessonTestTimers on LessonTestCubit {
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

  void _startTicker() {
    _stopTicker();
    if (state.attempt == null) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
