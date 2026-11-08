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

part 'lesson_test_cubit_answers.dart';
part 'lesson_test_cubit_attempt.dart';
part 'lesson_test_cubit_quiz_restore.dart';
part 'lesson_test_cubit_saves.dart';
part 'lesson_test_cubit_timers.dart';
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
