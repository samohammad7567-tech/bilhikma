import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/enums/blank_input_mode_enum.dart';
import 'package:bilhikma/core/enums/test_question_type_enum.dart';
import 'package:bilhikma/core/localization/lang_keys.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/lesson_test/data/models/lesson_test_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/question_start_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/question_timer_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_attempt_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_question_result_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_save_result_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_blank_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_match_item_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_option_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_question_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_sentence_model.dart';
import 'package:bilhikma/features/lesson_test/data/repos/lesson_test_repo.dart';
import 'package:bilhikma/features/lesson_test/presentation/cubit/lesson_test_cubit.dart';

void main() {
  group('LessonTestCubit', () {
    test('loads the quiz overview and waits for an explicit start', () async {
      final _FakeRepo repo = _FakeRepo();
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.status == LessonTestStatus.ready);

      expect(cubit.state.quiz?.id, 10);
      expect(cubit.state.quiz?.questionCount, 2);
      expect(cubit.state.canStart, isTrue);
      expect(repo.startCalls, 0);
    });

    test('starts in server order and preserves ordering order', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(questions: <TestQuestionModel>[_orderingQuestion()]),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      expect(repo.startCalls, 1);
      expect(cubit.state.answerOf('order').order, <String>['s2', 's1', 's3']);
      expect(cubit.state.currentQuestion?.id, 'order');
    });

    test('submits the selected answer and emits the server result', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.submittedAnswers, <String, Map<String, dynamic>>{
        'q1': <String, dynamic>{'option_id': 'o2'},
      });
      expect(cubit.state.result?.isPassed, isTrue);
      expect(cubit.state.result?.scorePercent, 100);
    });

    test(
      'keeps answers and stays running when the server rejects shape',
      () async {
        final _FakeRepo repo = _FakeRepo(
          attempt: _attempt(
            questions: <TestQuestionModel>[_singleChoiceQuestion()],
          ),
          submitError: const AppException(
            'validation_error',
            statusCode: 422,
            errors: <String, List<String>>{
              'answers': <String>['invalid_question_answer'],
            },
          ),
        );
        final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
        addTearDown(cubit.close);

        await _waitFor(() => cubit.state.isReady);
        await cubit.startAttempt();
        await _waitFor(() => cubit.state.isRunning);

        cubit.selectOption('o2');
        await cubit.submit();
        await _waitFor(
          () => cubit.state.errorKey == LangKeys.quizAnswersInvalid,
        );

        expect(cubit.state.isRunning, isTrue);
        expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);
        expect(cubit.state.validationErrors['answers'], isNotEmpty);

        repo.submitError = null;
        await cubit.submit();
        await _waitFor(() => cubit.state.isResult);

        expect(repo.submitCalls, 2);
      },
    );

    test(
      'recovers an already-submitted attempt into the result state',
      () async {
        final QuizAttemptModel submitted = _result();
        final _FakeRepo repo = _FakeRepo(
          attempt: _attempt(
            questions: <TestQuestionModel>[_singleChoiceQuestion()],
          ),
          submitError: const AppException(
            'quiz_already_submitted',
            statusCode: 422,
          ),
          attempts: <QuizAttemptModel>[submitted],
        );
        final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
        addTearDown(cubit.close);

        await _waitFor(() => cubit.state.isReady);
        await cubit.startAttempt();
        await _waitFor(() => cubit.state.isRunning);

        await cubit.submit();
        await _waitFor(() => cubit.state.isResult);

        expect(cubit.state.result?.id, submitted.id);
        expect(cubit.state.result?.isPassed, isTrue);
      },
    );

    test('maps start refusals back to the ready state', () async {
      final _FakeRepo repo = _FakeRepo(
        startError: const AppException('quiz_locked', statusCode: 403),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.errorKey == 'quiz_locked');

      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.isStarting, isFalse);
    });

    test('does not select beyond the maximum for multiple choice', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_multiChoiceQuestion()],
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o1');
      cubit.selectOption('o2');
      cubit.selectOption('o3');

      expect(cubit.state.answerOf('multi').optionIds, <String>['o1', 'o2']);
      expect(cubit.state.messageKey, LangKeys.quizMaxSelectionsReached);
    });

    test('serializes matching as right item to left item', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(questions: <TestQuestionModel>[_matchingQuestion()]),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectPrompt('l1');
      cubit.linkMatch('r1');
      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.submittedAnswers?['match'], <String, dynamic>{
        'matches': <String, String>{'r1': 'l1'},
      });
    });

    test('fills every blank with a reusable word bank item', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(questions: <TestQuestionModel>[_wordBankQuestion()]),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.assignWord('w1');
      cubit.assignWord('w1');

      expect(cubit.state.answerOf('fill').blanks, <String, String>{
        'b_1': 'w1',
        'b_2': 'w1',
      });
    });

    test('keeps one-to-many matches when the question allows it', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_oneToManyMatchingQuestion()],
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectPrompt('l1');
      cubit.linkMatch('r1');
      cubit.linkMatch('r2');
      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.submittedAnswers?['match'], <String, dynamic>{
        'matches': <String, String>{'r1': 'l1', 'r2': 'l1'},
      });
    });

    test('serializes dropdown choices from each blank', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(questions: <TestQuestionModel>[_dropdownQuestion()]),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectBlankChoice(blankId: 'b_1', optionId: 'choice_1');
      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.submittedAnswers?['fill'], <String, dynamic>{
        'blanks': <String, String>{'b_1': 'choice_1'},
      });
    });

    test('flags the timeout and submits the attempt once', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.didTimeOut);
      await _waitFor(() => cubit.state.isResult);

      expect(cubit.state.didTimeOut, isTrue);
      expect(repo.submitCalls, 1);
    });

    test('does not retry a timed out submission after a failure', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        ),
        submitError: const AppException('network_error'),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.didTimeOut);
      await _waitFor(() => repo.submitCalls == 1);
      await Future<void>.delayed(const Duration(milliseconds: 2300));

      expect(cubit.state.didTimeOut, isTrue);
      expect(cubit.state.isRunning, isTrue);
      expect(repo.submitCalls, 1);
    });

    test('submits the answers given so far when the student leaves', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[
            _singleChoiceQuestion(),
            _multiChoiceQuestion(),
          ],
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      final bool left = await cubit.submitAndLeave();
      await _waitFor(() => cubit.state.isResult);

      expect(left, isTrue);
      expect(repo.submittedAnswers, <String, Map<String, dynamic>>{
        'q1': <String, dynamic>{'option_id': 'o2'},
      });
    });

    test('stays running when the leave submission fails', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
        ),
        submitError: const AppException('network_error'),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      final bool left = await cubit.submitAndLeave();
      await _waitFor(() => cubit.state.errorKey != null);

      expect(left, isFalse);
      expect(cubit.state.isRunning, isTrue);
      expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);
    });
    test('does not submit an untouched ordering answer', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(questions: <TestQuestionModel>[_orderingQuestion()]),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.submittedAnswers, isEmpty);
    });

    test('restores server-saved answers when an attempt is resumed', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
          savedAnswers: <String, Map<String, dynamic>>{
            'q1': <String, dynamic>{'option_id': 'o2'},
          },
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);
    });

    test('ignores a saved ordering answer with unknown items', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_orderingQuestion()],
          savedAnswers: <String, Map<String, dynamic>>{
            'order': <String, dynamic>{
              'order': <String>['s1', 'unknown', 's3'],
            },
          },
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      expect(cubit.state.answerOf('order').order, <String>['s2', 's1', 's3']);
      expect(cubit.state.answerOf('order').isTouched, isFalse);
    });

    test('loads the latest submitted attempt in result-only mode', () async {
      final _FakeRepo repo = _FakeRepo(
        attempts: <QuizAttemptModel>[
          _result(id: 1, submittedAt: DateTime(2026, 1, 1)),
          _result(id: 2, submittedAt: DateTime(2026, 1, 2)),
        ],
      );
      final LessonTestCubit cubit = LessonTestCubit(
        lessonId: 4,
        repo: repo,
        resultOnly: true,
        initialQuizId: 10,
      );
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isResult);

      expect(cubit.state.result?.id, 2);
      expect(cubit.state.resultOnly, isTrue);
    });

    test(
      'loads the full attempt detail for review without starting an attempt',
      () async {
        final _FakeRepo repo = _FakeRepo(
          fetchedAttempt: _result(
            id: 77,
            questionResults: <QuizQuestionResultModel>[
              const QuizQuestionResultModel(
                questionId: 'q1',
                questionType: TestQuestionType.singleChoice,
                isCorrect: true,
                givenAnswer: <String, dynamic>{'option_id': 'o2'},
                solution: <String, dynamic>{'correct_option_id': 'o2'},
              ),
            ],
          ),
        );
        final LessonTestCubit cubit = LessonTestCubit(
          lessonId: 4,
          repo: repo,
          resultOnly: true,
          initialQuizId: 10,
          initialAttemptId: 77,
        );
        addTearDown(cubit.close);

        await _waitFor(() => cubit.state.isResult);

        expect(cubit.state.result?.id, 77);
        expect(cubit.state.result?.questionResults, hasLength(1));
        expect(repo.startCalls, 0);
        expect(repo.fetchAttemptCalls, 1);
      },
    );

    test('falls back to the attempts list when the detail fails', () async {
      final _FakeRepo repo = _FakeRepo(
        attempts: <QuizAttemptModel>[_result(id: 2)],
        fetchAttemptError: const AppException('quiz_unavailable'),
      );
      final LessonTestCubit cubit = LessonTestCubit(
        lessonId: 4,
        repo: repo,
        resultOnly: true,
        initialQuizId: 10,
        initialAttemptId: 2,
      );
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isResult);

      expect(cubit.state.result?.id, 2);
      expect(repo.startCalls, 0);
    });

    test('reports the local save state after an answer changes', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');

      expect(cubit.state.saveStatus, LessonTestSaveStatus.saving);

      await _waitFor(
        () => cubit.state.saveStatus == LessonTestSaveStatus.saved,
      );
    });

    test('opens the first question on the server after starting', () async {
      final _FakeRepo repo = _FakeRepo();
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => repo.startQuestionCalls == 1);

      expect(repo.startQuestionCalls, 1);
      expect(cubit.state.openedQuestionIds, contains('q1'));
      expect(cubit.state.openingQuestionId, isNull);
    });

    test('opens on navigation without resetting earlier timers', () async {
      final DateTime expiresAt = DateTime.now().add(
        const Duration(seconds: 40),
      );
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[
            _singleChoiceQuestion(),
            _multiChoiceQuestion(),
          ],
        ),
        questionTimer: QuestionTimerModel(
          enabled: true,
          startedAt: DateTime.now(),
          expiresAt: expiresAt,
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.openedQuestionIds.contains('q1'));

      cubit.goNext();
      await _waitFor(() => cubit.state.openedQuestionIds.contains('multi'));

      expect(repo.startQuestionCalls, 2);
      expect(cubit.state.questionTimers['q1']?.expiresAt, expiresAt);

      cubit.goPrevious();
      await _waitFor(() => repo.startQuestionCalls == 3);

      expect(cubit.state.currentQuestion?.id, 'q1');
      expect(cubit.state.questionTimers['q1']?.expiresAt, expiresAt);
    });

    test('derives the countdown from the server clock', () async {
      final DateTime serverNow = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      final _FakeRepo repo = _FakeRepo(
        startServerNow: serverNow,
        questionTimer: QuestionTimerModel(
          enabled: true,
          startedAt: serverNow,
          expiresAt: serverNow.add(const Duration(seconds: 30)),
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.openedQuestionIds.contains('q1'));

      final Duration? remaining = cubit.state.currentQuestionRemaining;

      expect(remaining, isNotNull);
      expect(remaining! <= const Duration(seconds: 30), isTrue);
      expect(remaining > const Duration(seconds: 25), isTrue);
    });

    test('does not open questions for a legacy attempt', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
          questionTimingEnabled: false,
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.startQuestionCalls, 0);
      expect(cubit.state.openedQuestionIds, contains('q1'));
      expect(cubit.state.isCurrentQuestionLocked, isFalse);
    });

    test('locks the question when the start response is expired', () async {
      final _FakeRepo repo = _FakeRepo(
        questionTimer: QuestionTimerModel(
          enabled: true,
          startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
          hasExpired: true,
          canAnswer: false,
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isCurrentQuestionLocked);

      expect(cubit.state.isRunning, isTrue);
      expect(repo.submitCalls, 0);
      expect(cubit.state.currentQuestionRemaining, Duration.zero);
    });

    test('sends an edited answer to the server after the debounce', () async {
      final _FakeRepo repo = _FakeRepo();
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      await _waitFor(() => repo.saveAnswersCalls == 1);

      expect(repo.savedAnswersPayload?['q1'], <String, dynamic>{
        'option_id': 'o2',
      });
    });

    test('locks a question listed in ignored_question_ids', () async {
      final _FakeRepo repo = _FakeRepo()..ignoredQuestionIds = <String>['q1'];
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      await _waitFor(() => cubit.state.isCurrentQuestionLocked);

      cubit.selectOption('o1');

      expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);
    });

    test('hydrates the saved answer returned by the start call', () async {
      final _FakeRepo repo = _FakeRepo(
        savedAnswer: <String, dynamic>{'option_id': 'o2'},
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.openedQuestionIds.contains('q1'));

      expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);
    });

    test(
      're-saves a touched answer when the server returns an older one',
      () async {
        final _FakeRepo repo = _FakeRepo(
          savedAnswer: <String, dynamic>{'option_id': 'o2'},
        );
        final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
        addTearDown(cubit.close);

        await _waitFor(() => cubit.state.isReady);
        await cubit.startAttempt();
        await _waitFor(() => cubit.state.isRunning);

        cubit.selectOption('o1');
        await _waitFor(() => repo.saveAnswersCalls == 1);
        expect(cubit.state.answerOf('q1').optionIds, <String>['o1']);

        await cubit.reopenCurrentQuestion();
        await _waitFor(() => repo.saveAnswersCalls >= 2);

        expect(repo.savedAnswersPayload?['q1'], <String, dynamic>{
          'option_id': 'o1',
        });
        expect(cubit.state.answerOf('q1').optionIds, <String>['o1']);
      },
    );

    test('reports a question that could not be opened', () async {
      final _FakeRepo repo = _FakeRepo(
        startQuestionError: const AppException('network_error'),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(
        () => cubit.state.messageKey == LangKeys.quizQuestionOpenFailed,
      );

      expect(cubit.state.openingQuestionId, isNull);
      expect(cubit.state.isRunning, isTrue);
    });

    test('retries a failed remote save before submitting', () async {
      final _FakeRepo repo = _FakeRepo()
        ..saveAnswersError = const AppException('network_error');
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.isRunning);

      cubit.selectOption('o2');
      await _waitFor(() => repo.saveAnswersCalls == 1);
      expect(cubit.state.answerOf('q1').optionIds, <String>['o2']);

      repo.saveAnswersError = null;
      await cubit.submit();
      await _waitFor(() => cubit.state.isResult);

      expect(repo.saveAnswersCalls, greaterThanOrEqualTo(2));
      expect(repo.submittedAnswers?['q1'], <String, dynamic>{
        'option_id': 'o2',
      });
    });

    test(
      'hides the test when the save fails offline and resumes on retry',
      () async {
        final _FakeRepo repo = _FakeRepo()
          ..saveAnswersError = const AppException(ErrorMapper.noInternetKey);
        final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
        addTearDown(cubit.close);

        await _waitFor(() => cubit.state.isReady);
        await cubit.startAttempt();
        await _waitFor(() => cubit.state.isRunning);

        cubit.selectOption('o2');
        await _waitFor(() => cubit.state.hasFailed);

        expect(cubit.state.errorKey, ErrorMapper.noInternetKey);
        expect(cubit.state.isRunning, isFalse);
        expect(cubit.state.attempt?.id, 100);

        repo.saveAnswersError = null;
        await cubit.retry();
        await _waitFor(() => cubit.state.isRunning);

        expect(cubit.state.hasFailed, isFalse);
      },
    );

    test('keeps the server reason when the quiz is refused', () async {
      final _FakeRepo repo = _FakeRepo(
        attempt: _attempt(
          questions: <TestQuestionModel>[_singleChoiceQuestion()],
        ),
        startError: const AppException(
          'forbidden',
          statusCode: 403,
          message: 'article must be read before starting the quiz',
        ),
      );
      final LessonTestCubit cubit = LessonTestCubit(lessonId: 4, repo: repo);
      addTearDown(cubit.close);

      await _waitFor(() => cubit.state.isReady);
      await cubit.startAttempt();
      await _waitFor(() => cubit.state.errorKey != null);

      expect(cubit.state.errorKey, LangKeys.quizArticleNotRead);
      expect(cubit.state.errorMessage, contains('article'));
    });
  });
}

Future<void> _waitFor(bool Function() predicate) async {
  for (int i = 0; i < 600; i++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('state did not settle');
}

class _FakeRepo extends LessonTestRepo {
  _FakeRepo({
    this.attempt,
    this.fetchedAttempt,
    this.submitError,
    this.startError,
    this.fetchAttemptError,
    this.startQuestionError,
    this.questionTimer,
    this.savedAnswer,
    this.startServerNow,
    List<QuizAttemptModel>? attempts,
  }) : attempts = attempts ?? const <QuizAttemptModel>[];

  QuizAttemptModel? attempt;
  QuizAttemptModel? fetchedAttempt;
  Object? submitError;
  Object? startError;
  Object? fetchAttemptError;
  Object? startQuestionError;
  Object? saveAnswersError;
  QuestionTimerModel? questionTimer;
  Map<String, dynamic>? savedAnswer;
  DateTime? startServerNow;
  List<String> ignoredQuestionIds = <String>[];
  List<QuizAttemptModel> attempts;

  int startCalls = 0;
  int submitCalls = 0;
  int fetchAttemptCalls = 0;
  int startQuestionCalls = 0;
  int saveAnswersCalls = 0;
  Map<String, Map<String, dynamic>>? submittedAnswers;
  Map<String, Map<String, dynamic>>? savedAnswersPayload;

  @override
  Future<LessonTestModel> fetchQuiz(int contentId) async => LessonTestModel(
    id: 10,
    title: 'Quiz',
    questionCount: 2,
    attemptsLeft: 3,
    timeLimitMinutes: 10,
  );

  @override
  Future<QuizAttemptModel> startAttempt(int quizId) async {
    startCalls++;

    final Object? error = startError;
    if (error != null) throw error;

    return attempt ?? _attempt();
  }

  @override
  Future<QuestionStartModel> startQuestion(
    int attemptId,
    String questionId,
  ) async {
    startQuestionCalls++;

    final Object? error = startQuestionError;
    if (error != null) throw error;

    return QuestionStartModel(
      attemptId: attemptId,
      questionId: questionId,
      serverNow: startServerNow ?? DateTime.now(),
      timer:
          questionTimer ??
          const QuestionTimerModel(enabled: false, canAnswer: true),
      savedAnswer: savedAnswer,
    );
  }

  @override
  Future<QuizSaveResultModel> saveAnswers(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) async {
    saveAnswersCalls++;
    savedAnswersPayload = answers;

    final Object? error = saveAnswersError;
    if (error != null) throw error;

    return QuizSaveResultModel(
      attemptId: attemptId,
      saved: answers.length,
      ignoredQuestionIds: ignoredQuestionIds,
      serverNow: DateTime.now(),
    );
  }

  @override
  Future<QuizAttemptModel> submitAttempt(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) async {
    submitCalls++;
    submittedAnswers = answers;

    final Object? error = submitError;
    if (error != null) throw error;

    return _result();
  }

  @override
  Future<List<QuizAttemptModel>> fetchMyAttempts(int quizId) async => attempts;

  @override
  Future<QuizAttemptModel> fetchAttempt(int attemptId) async {
    fetchAttemptCalls++;

    final Object? error = fetchAttemptError;
    if (error != null) throw error;

    return fetchedAttempt ?? _result(id: attemptId);
  }
}

QuizAttemptModel _attempt({
  List<TestQuestionModel>? questions,
  DateTime? expiresAt,
  bool questionTimingEnabled = true,
  Map<String, Map<String, dynamic>> savedAnswers =
      const <String, Map<String, dynamic>>{},
}) => QuizAttemptModel(
  id: 100,
  quizId: 10,
  studentId: 1,
  attemptNo: 1,
  expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 10)),
  questionTimingEnabled: questionTimingEnabled,
  questions: questions ?? <TestQuestionModel>[_singleChoiceQuestion()],
  savedAnswers: savedAnswers,
);

QuizAttemptModel _result({
  int id = 100,
  DateTime? submittedAt,
  List<QuizQuestionResultModel> questionResults =
      const <QuizQuestionResultModel>[],
}) => QuizAttemptModel(
  id: id,
  quizId: 10,
  studentId: 1,
  attemptNo: 1,
  score: 1,
  maxScore: 1,
  scorePercent: 100,
  isPassed: true,
  submittedAt: submittedAt ?? DateTime.now(),
  questions: <TestQuestionModel>[_singleChoiceQuestion()],
  questionResults: questionResults,
);

TestQuestionModel _singleChoiceQuestion() => const TestQuestionModel(
  id: 'q1',
  type: TestQuestionType.singleChoice,
  prompt: 'Pick one',
  options: <TestOptionModel>[
    TestOptionModel(id: 'o1', label: 'One'),
    TestOptionModel(id: 'o2', label: 'Two'),
  ],
);

TestQuestionModel _multiChoiceQuestion() => const TestQuestionModel(
  id: 'multi',
  type: TestQuestionType.multiChoice,
  prompt: 'Pick two',
  maxSelections: 2,
  options: <TestOptionModel>[
    TestOptionModel(id: 'o1', label: 'One'),
    TestOptionModel(id: 'o2', label: 'Two'),
    TestOptionModel(id: 'o3', label: 'Three'),
  ],
);

TestQuestionModel _orderingQuestion() => const TestQuestionModel(
  id: 'order',
  type: TestQuestionType.orderSentences,
  prompt: 'Order',
  sentences: <TestSentenceModel>[
    TestSentenceModel(id: 's2', text: 'Second'),
    TestSentenceModel(id: 's1', text: 'First'),
    TestSentenceModel(id: 's3', text: 'Third'),
  ],
);

TestQuestionModel _matchingQuestion() => const TestQuestionModel(
  id: 'match',
  type: TestQuestionType.matchPairs,
  prompt: 'Match',
  leftItems: <TestMatchItemModel>[TestMatchItemModel(id: 'l1', text: 'Left')],
  rightItems: <TestMatchItemModel>[TestMatchItemModel(id: 'r1', text: 'Right')],
);

TestQuestionModel _wordBankQuestion() => const TestQuestionModel(
  id: 'fill',
  type: TestQuestionType.fillBlanks,
  prompt: 'Complete {{1}} and {{2}}',
  body: 'Complete {{b_1}} and {{b_2}}',
  blankInputMode: BlankInputMode.wordBank,
  options: <TestOptionModel>[
    TestOptionModel(id: 'w1', label: 'word', isReusable: true),
  ],
  blanks: <TestBlankModel>[
    TestBlankModel(id: 'b_1', blankIndex: 1),
    TestBlankModel(id: 'b_2', blankIndex: 2),
  ],
);

TestQuestionModel _oneToManyMatchingQuestion() => const TestQuestionModel(
  id: 'match',
  type: TestQuestionType.matchPairs,
  prompt: 'Match',
  allowsOneToManyMatching: true,
  leftItems: <TestMatchItemModel>[TestMatchItemModel(id: 'l1', text: 'Left')],
  rightItems: <TestMatchItemModel>[
    TestMatchItemModel(id: 'r1', text: 'Right one'),
    TestMatchItemModel(id: 'r2', text: 'Right two'),
  ],
);

TestQuestionModel _dropdownQuestion() => const TestQuestionModel(
  id: 'fill',
  type: TestQuestionType.fillBlanks,
  prompt: 'Complete {{1}}',
  body: 'Complete {{b_1}}',
  blankInputMode: BlankInputMode.dropdown,
  blanks: <TestBlankModel>[
    TestBlankModel(
      id: 'b_1',
      blankIndex: 1,
      choices: <TestOptionModel>[
        TestOptionModel(id: 'choice_1', label: 'Choice'),
      ],
    ),
  ],
);
