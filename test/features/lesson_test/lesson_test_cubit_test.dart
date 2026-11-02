import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/enums/blank_input_mode_enum.dart';
import 'package:bilhikma/core/enums/test_question_type_enum.dart';
import 'package:bilhikma/core/localization/lang_keys.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/lesson_test/data/models/lesson_test_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_attempt_model.dart';
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
    this.submitError,
    this.startError,
    List<QuizAttemptModel>? attempts,
  }) : attempts = attempts ?? const <QuizAttemptModel>[];

  QuizAttemptModel? attempt;
  Object? submitError;
  Object? startError;
  List<QuizAttemptModel> attempts;

  int startCalls = 0;
  int submitCalls = 0;
  Map<String, Map<String, dynamic>>? submittedAnswers;

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
}

QuizAttemptModel _attempt({
  List<TestQuestionModel>? questions,
  DateTime? expiresAt,
}) => QuizAttemptModel(
  id: 100,
  quizId: 10,
  studentId: 1,
  attemptNo: 1,
  expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 10)),
  questions: questions ?? <TestQuestionModel>[_singleChoiceQuestion()],
);

QuizAttemptModel _result() => QuizAttemptModel(
  id: 100,
  quizId: 10,
  studentId: 1,
  attemptNo: 1,
  score: 1,
  maxScore: 1,
  scorePercent: 100,
  isPassed: true,
  submittedAt: DateTime.now(),
  questions: <TestQuestionModel>[_singleChoiceQuestion()],
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
