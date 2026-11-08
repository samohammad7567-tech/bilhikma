part of 'lesson_test_cubit.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension LessonTestAnswers on LessonTestCubit {
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

  String? _firstEmptyBlank(TestQuestionModel question) {
    final TestAnswerModel current = state.currentAnswer;

    for (final blank in question.blanks) {
      if (!current.blanks.containsKey(blank.id)) return blank.id;
    }
    return null;
  }
}
