import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/localization/lang_keys.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/data_source/lesson_test_local_data_source.dart';
import '../../data/models/lesson_test_model.dart';
import '../../data/models/quiz_attempt_model.dart';
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
  bool _startRequested = false;
  bool _submitRequested = false;
  int _saveRevision = 0;

  Future<void> retry() => state.resultOnly || resultOnly
      ? loadResult(quizId: initialQuizId, attemptId: initialAttemptId)
      : loadQuiz();

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
    _cacheTimer?.cancel();
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
    _cacheTimer?.cancel();
    _startRequested = false;
    _submitRequested = false;

    emit(
      const LessonTestState(status: LessonTestStatus.loading, resultOnly: true),
    );

    LessonTestModel? quiz;
    try {
      quiz = await repo.fetchQuiz(lessonId);
    } catch (_) {
      quiz = null;
    }
    if (isClosed) return;

    final int? resolvedQuizId = quizId ?? quiz?.id;
    if (resolvedQuizId == null) {
      _emitResultFailure(const AppException(LangKeys.quizResultUnavailable));
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

      QuizAttemptModel? target;
      if (attemptId != null) {
        for (final QuizAttemptModel attempt in submitted) {
          if (attempt.id == attemptId) {
            target = attempt;
            break;
          }
        }
      }
      target ??= submitted.isEmpty ? null : submitted.first;

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
    } catch (error) {
      if (isClosed) return;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );
      _emitResultFailure(exception);
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

    if (_startRequested ||
        state.isStarting ||
        !state.canStart ||
        quiz == null) {
      return;
    }

    _startRequested = true;

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

      emit(
        state.copyWith(
          status: LessonTestStatus.running,
          attempt: attempt,
          answers: _restoredAnswers(attempt),
          rightOrder: _initialRightOrder(attempt),
          currentIndex: 0,
          remaining: _remainingOf(attempt),
          questionStartedAt: DateTime.now(),
          questionTick: 0,
          isStarting: false,
          didTimeOut: false,
          clearSelectedBlank: true,
          clearSelectedPrompt: true,
          clearError: true,
          clearMessage: true,
        ),
      );

      _startTicker();
    } catch (error) {
      if (isClosed) return;

      final AppException exception = QuizErrorMapper.translate(
        ErrorMapper.toException(error),
      );

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

  void selectBlank(String blankId) => state.selectedBlankId == blankId
      ? emit(state.copyWith(clearSelectedBlank: true))
      : emit(state.copyWith(selectedBlankId: blankId));

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

  void selectPrompt(String leftItemId) => state.selectedPromptId == leftItemId
      ? emit(state.copyWith(clearSelectedPrompt: true))
      : emit(state.copyWith(selectedPromptId: leftItemId));

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

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));

  Future<void> flushAnswers() async {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    await _persistAnswers();
  }

  @override
  Future<void> close() async {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    await _persistAnswers(report: false);
    _stopTicker();
    return super.close();
  }

  void _tick() {
    if (state.status != LessonTestStatus.running || state.didTimeOut) return;

    final DateTime? expiresAt = state.attempt?.expiresAt;
    final bool hasQuestionTimer = state.currentQuestion?.timeLimit != null;

    if (expiresAt == null && !hasQuestionTimer) return;

    if (expiresAt != null) {
      final Duration remaining = expiresAt.difference(DateTime.now());

      if (remaining <= Duration.zero) {
        emit(state.copyWith(remaining: Duration.zero, didTimeOut: true));
        unawaited(submit(timedOut: true));
        return;
      }

      emit(
        state.copyWith(
          remaining: remaining,
          questionTick: state.questionTick + 1,
        ),
      );
      return;
    }

    emit(state.copyWith(questionTick: state.questionTick + 1));
  }

  void _moveTo(int index) {
    emit(
      state.copyWith(
        currentIndex: index,
        questionStartedAt: DateTime.now(),
        questionTick: 0,
        clearSelectedBlank: true,
        clearSelectedPrompt: true,
      ),
    );

    _startTicker();
  }

  void _emitAnswer(
    TestAnswerModel answer, {
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
  }) {
    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    _saveRevision++;

    emit(
      state.copyWith(
        answers: Map<String, TestAnswerModel>.of(state.answers)
          ..[question.id] = answer.copyWith(isTouched: true),
        saveStatus: LessonTestSaveStatus.saving,
        clearSelectedBlank: clearSelectedBlank,
        clearSelectedPrompt: clearSelectedPrompt,
      ),
    );

    _schedulePersist();
  }

  void _emitResult(QuizAttemptModel result, {bool timedOut = false}) {
    _stopTicker();
    _cacheTimer?.cancel();
    _cacheTimer = null;
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

  Duration _remainingOf(QuizAttemptModel attempt) {
    final DateTime? expiresAt = attempt.expiresAt;
    if (expiresAt == null) return Duration.zero;

    final Duration remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
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
