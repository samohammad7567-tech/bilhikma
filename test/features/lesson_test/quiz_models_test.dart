import 'package:bilhikma/core/enums/blank_input_mode_enum.dart';
import 'package:bilhikma/core/enums/test_question_type_enum.dart';
import 'package:bilhikma/core/network/session_policy.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/lesson_test/data/models/lesson_test_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_attempt_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_question_result_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_answer_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_match_item_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_option_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_question_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_sentence_model.dart';
import 'package:bilhikma/features/lesson_test/presentation/refactor/test_solution_answers.dart';
import 'package:bilhikma/features/lesson_detail/data/models/lesson_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _attempt({
  required String id,
  required String type,
  required String text,
  Map<String, dynamic> details = const <String, dynamic>{},
}) => <String, dynamic>{
  'question_id': id,
  'question_text': text,
  'question_type': type,
  'score': 2,
  'options': <String, dynamic>{'default_time_seconds': 60, 'details': details},
  'selected_option_id': null,
  'selected_boolean': null,
  'answer_text': null,
  'is_correct': null,
  'awarded_score': null,
  'given_answer': null,
};

void main() {
  group('quiz overview', () {
    test('parses server overview values', () {
      final LessonTestModel quiz = LessonTestModel.fromJson(<String, dynamic>{
        'id': 2,
        'content_id': 11,
        'title': 'Quiz',
        'instructions': 'Read carefully',
        'pass_score': 60,
        'max_attempts': null,
        'retry_cooldown_minutes': 15,
        'time_limit_minutes': null,
        'shuffle_questions': true,
        'is_blocking': true,
        'show_correct_answers': false,
        'is_published': true,
        'selection_mode': 'random',
        'question_count': 7,
        'total_score': 14,
        'attempts_used': 1,
        'attempts_left': null,
        'has_passed': false,
        'next_attempt_at': null,
      });

      expect(quiz.id, 2);
      expect(quiz.contentId, 11);
      expect(quiz.passScore, 60);
      expect(quiz.hasUnlimitedAttempts, isTrue);
      expect(quiz.hasTimeLimit, isFalse);
      expect(quiz.questionCount, 7);
      expect(quiz.isBlocking, isTrue);
    });
  });

  group('attempt parsing', () {
    test('parses all seven question types', () {
      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{
          'id': 5,
          'quiz_id': 2,
          'student_id': 9,
          'attempt_no': 1,
          'max_score': 14,
          'review_status': 'none',
          'started_at': '2099-01-01T10:00:00Z',
          'expires_at': '2099-01-01T10:30:00Z',
          'has_expired': false,
          'policy_snapshot': <String, dynamic>{'pass_score': 60},
          'answers': <Map<String, dynamic>>[
            _attempt(
              id: '1',
              type: 'mcq_single',
              text: 'Pick one',
              details: <String, dynamic>{
                'choice_variant': 'best_answer',
                'options': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'o1', 'text': 'A'},
                  <String, dynamic>{'id': 'o2', 'text': 'B'},
                ],
              },
            ),
            _attempt(
              id: '2',
              type: 'mcq_multiple',
              text: 'Pick many',
              details: <String, dynamic>{
                'max_selections': 2,
                'options': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'o3', 'text': 'C'},
                  <String, dynamic>{'id': 'o4', 'text': 'D'},
                ],
              },
            ),
            _attempt(id: '3', type: 'true_false', text: 'True?'),
            _attempt(
              id: '4',
              type: 'fill_blank_choice',
              text: 'Choose {{1}}',
              details: <String, dynamic>{
                'blank_input_mode': 'word_bank',
                'word_bank': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'w1', 'text': 'word'},
                ],
                'blanks': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'b_1', 'blank_index': 1},
                ],
              },
            ),
            _attempt(
              id: '5',
              type: 'fill_blank_typed',
              text: 'Type {{1}}',
              details: <String, dynamic>{
                'blanks': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'b_1',
                    'blank_index': 1,
                    'max_length': 30,
                  },
                ],
              },
            ),
            _attempt(
              id: '6',
              type: 'matching',
              text: 'Match',
              details: <String, dynamic>{
                'pairs': <String, dynamic>{
                  'left': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'l1', 'text': 'Left'},
                  ],
                  'right': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'r1', 'text': 'Right'},
                  ],
                },
              },
            ),
            _attempt(
              id: '7',
              type: 'ordering',
              text: 'Order',
              details: <String, dynamic>{
                'items': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'i1', 'text': 'One'},
                  <String, dynamic>{'id': 'i2', 'text': 'Two'},
                ],
              },
            ),
          ],
        },
      );

      expect(attempt.questions, hasLength(7));
      expect(attempt.questions[0].type, TestQuestionType.singleChoice);
      expect(attempt.questions[0].isBestAnswer, isTrue);
      expect(attempt.questions[1].effectiveMaxSelections, 2);
      expect(attempt.questions[2].type, TestQuestionType.trueFalse);
      expect(attempt.questions[3].blankInputMode, BlankInputMode.wordBank);
      expect(attempt.questions[3].body, 'Choose {{b_1}}');
      expect(attempt.questions[4].body, 'Type {{b_1}}');
      expect(attempt.questions[5].rightItems.single.id, 'r1');
      expect(attempt.questions[6].sentences, hasLength(2));
      expect(attempt.isSubmitted, isFalse);
      expect(attempt.hasExpired, isFalse);
    });

    test('treats empty options and null default time as no question timer', () {
      final TestQuestionModel emptyOptions =
          TestQuestionModel.fromJson(<String, dynamic>{
            'question_id': 36,
            'question_text': 'True?',
            'question_type': 'true_false',
            'score': 2,
            'options': <dynamic>[],
          });

      expect(emptyOptions.type, TestQuestionType.trueFalse);
      expect(emptyOptions.timeLimit, isNull);

      final TestQuestionModel nullTime = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 32,
          'question_text': 'Pick one',
          'question_type': 'mcq_single',
          'score': 2,
          'options': <String, dynamic>{
            'default_time_seconds': null,
            'details': <String, dynamic>{
              'options': <Map<String, dynamic>>[
                <String, dynamic>{'id': 'o_1', 'text': 'One'},
              ],
            },
          },
        },
      );

      expect(nullTime.timeLimit, isNull);
      expect(nullTime.options.single.label, 'One');
    });

    test('parses reusable words, one-to-many matching, and duration', () {
      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{
          'id': 5,
          'quiz_id': 2,
          'student_id': 9,
          'attempt_no': 1,
          'max_score': 14,
          'duration_seconds': 95,
          'review_status': 'none',
          'answers': <Map<String, dynamic>>[
            _attempt(
              id: '4',
              type: 'fill_blank_choice',
              text: 'Choose {{1}} and {{2}}',
              details: <String, dynamic>{
                'blank_input_mode': 'word_bank',
                'word_bank': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'w1',
                    'text': 'word',
                    'is_reusable': true,
                  },
                ],
                'blanks': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 'b_1', 'blank_index': 1},
                  <String, dynamic>{'id': 'b_2', 'blank_index': 2},
                ],
              },
            ),
            _attempt(
              id: '6',
              type: 'matching',
              text: 'Match',
              details: <String, dynamic>{
                'allow_one_to_many_matching': true,
                'pairs': <String, dynamic>{
                  'left': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'l1', 'text': 'Left'},
                  ],
                  'right': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'r1', 'text': 'Right'},
                  ],
                },
              },
            ),
          ],
        },
      );

      expect(attempt.duration, const Duration(seconds: 95));
      expect(attempt.questions[0].options.single.isReusable, isTrue);
      expect(attempt.questions[1].allowsOneToManyMatching, isTrue);
    });

    test('parses question and option media paths', () {
      final TestQuestionModel question = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 38,
          'question_text': 'Pick the red card',
          'question_type': 'mcq_single',
          'score': 4,
          'options': <String, dynamic>{
            'default_time_seconds': 45,
            'image_path':
                'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
            'audio_path': 'qa-quiz-fields/tone.wav',
            'details': <String, dynamic>{
              'options': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'red',
                  'text': 'Red',
                  'image_path': 'qa-quiz-fields/card-a.png',
                  'audio_path': 'qa-quiz-fields/red.wav',
                },
              ],
            },
          },
        },
      );

      expect(
        question.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
      );
      expect(
        question.audioUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/tone.wav',
      );
      expect(
        question.options.single.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
      );
      expect(
        question.options.single.audioUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/red.wav',
      );
    });

    test('handles options that only carry an image', () {
      final TestQuestionModel question = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 39,
          'question_text': 'Pick the red card',
          'question_type': 'mcq_single',
          'score': 4,
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'options': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'red',
                  'text': '',
                  'image_path': 'qa-quiz-fields/card-a.png',
                },
                <String, dynamic>{
                  'id': 'blue',
                  'text': '',
                  'label': 'Blue',
                  'image_path': 'qa-quiz-fields/card-b.png',
                },
              ],
            },
          },
        },
      );

      final TestOptionModel imageOnly = question.options[0];
      expect(imageOnly.label, isEmpty);
      expect(
        imageOnly.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
      );
      expect(question.options[1].label, 'Blue');
    });

    test('parses media on ordering and matching items', () {
      final TestQuestionModel ordering = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 49,
          'question_text': 'Order the cards',
          'question_type': 'ordering',
          'score': 4,
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'red',
                  'text': '',
                  'image_path': 'qa-quiz-fields/card-a.png',
                  'audio_path': 'qa-quiz-fields/card-a.wav',
                },
              ],
            },
          },
        },
      );

      expect(ordering.sentences.single.text, isEmpty);
      expect(
        ordering.sentences.single.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
      );
      expect(
        ordering.sentences.single.audioUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.wav',
      );

      final TestQuestionModel matching = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 50,
          'question_text': 'Match the cards',
          'question_type': 'matching',
          'score': 4,
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'pairs': <String, dynamic>{
                'left': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'red',
                    'text': '',
                    'image_path': 'qa-quiz-fields/card-a.png',
                  },
                ],
                'right': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'blue',
                    'text': '',
                    'image_path': 'qa-quiz-fields/card-b.png',
                    'audio_path': 'qa-quiz-fields/card-b.wav',
                  },
                ],
              },
            },
          },
        },
      );

      expect(
        matching.leftItems.single.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-a.png',
      );
      expect(
        matching.rightItems.single.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-b.png',
      );
      expect(
        matching.rightItems.single.audioUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/card-b.wav',
      );
    });

    test('marks a submitted attempt from score even without submitted_at', () {
      final QuizAttemptModel attempt =
          QuizAttemptModel.fromJson(<String, dynamic>{
            'id': 5,
            'quiz_id': 2,
            'student_id': 9,
            'attempt_no': 1,
            'score': 10,
            'max_score': 14,
            'review_status': 'none',
            'answers': <Map<String, dynamic>>[],
          });

      expect(attempt.isSubmitted, isTrue);
    });
  });

  group('answer serialization', () {
    const TestQuestionModel single = TestQuestionModel(
      id: '1',
      type: TestQuestionType.singleChoice,
      prompt: 'Pick one',
      options: <TestOptionModel>[
        TestOptionModel(id: 'o1', label: 'A'),
        TestOptionModel(id: 'o2', label: 'B'),
      ],
    );

    const TestQuestionModel multiple = TestQuestionModel(
      id: '2',
      type: TestQuestionType.multiChoice,
      prompt: 'Pick many',
      options: <TestOptionModel>[
        TestOptionModel(id: 'o1', label: 'A'),
        TestOptionModel(id: 'o2', label: 'B'),
      ],
      maxSelections: 2,
    );

    const TestQuestionModel matching = TestQuestionModel(
      id: '6',
      type: TestQuestionType.matchPairs,
      prompt: 'Match',
      leftItems: <TestMatchItemModel>[
        TestMatchItemModel(id: 'l1', text: 'Left'),
      ],
      rightItems: <TestMatchItemModel>[
        TestMatchItemModel(id: 'r1', text: 'Right'),
      ],
    );

    const TestQuestionModel ordering = TestQuestionModel(
      id: '7',
      type: TestQuestionType.orderSentences,
      prompt: 'Order',
      sentences: <TestSentenceModel>[
        TestSentenceModel(id: 'i1', text: 'One'),
        TestSentenceModel(id: 'i2', text: 'Two'),
      ],
    );

    test('uses the exact server keys and types', () {
      expect(
        const TestAnswerModel(
          optionIds: <String>['o1'],
        ).toSubmissionJson(single),
        <String, dynamic>{'option_id': 'o1'},
      );
      expect(
        const TestAnswerModel(
          optionIds: <String>['o1', 'o2'],
        ).toSubmissionJson(multiple),
        <String, dynamic>{
          'option_ids': <String>['o1', 'o2'],
        },
      );
      expect(
        const TestAnswerModel(boolean: true).toSubmissionJson(
          const TestQuestionModel(
            id: '3',
            type: TestQuestionType.trueFalse,
            prompt: 'True?',
          ),
        ),
        <String, dynamic>{'boolean': true},
      );
      expect(
        const TestAnswerModel(
          matches: <String, String>{'r1': 'l1'},
        ).toSubmissionJson(matching),
        <String, dynamic>{
          'matches': <String, String>{'r1': 'l1'},
        },
      );
      expect(
        const TestAnswerModel(
          order: <String>['i2', 'i1'],
        ).toSubmissionJson(ordering),
        <String, dynamic>{
          'order': <String>['i2', 'i1'],
        },
      );
    });

    test('allows one-to-many matches only when the question permits it', () {
      const TestQuestionModel oneToMany = TestQuestionModel(
        id: '6',
        type: TestQuestionType.matchPairs,
        prompt: 'Match',
        allowsOneToManyMatching: true,
        leftItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'l1', text: 'Left'),
        ],
        rightItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'r1', text: 'Right one'),
          TestMatchItemModel(id: 'r2', text: 'Right two'),
        ],
      );

      expect(
        const TestAnswerModel(
          matches: <String, String>{'r1': 'l1', 'r2': 'l1'},
        ).toSubmissionJson(oneToMany),
        <String, dynamic>{
          'matches': <String, String>{'r1': 'l1', 'r2': 'l1'},
        },
      );
    });

    test('rejects invalid structures without judging correctness', () {
      expect(
        () => const TestAnswerModel(
          optionIds: <String>['o1', 'o1'],
        ).toSubmissionJson(multiple),
        throwsA(isA<AnswerValidationException>()),
      );
      expect(
        () => const TestAnswerModel(
          optionIds: <String>['missing'],
        ).toSubmissionJson(single),
        throwsA(isA<AnswerValidationException>()),
      );
      expect(
        () => const TestAnswerModel(
          matches: <String, String>{'r1': 'l1', 'r2': 'l1'},
        ).toSubmissionJson(matching),
        throwsA(isA<AnswerValidationException>()),
      );
      expect(
        () => const TestAnswerModel(
          order: <String>['i1'],
        ).toSubmissionJson(ordering),
        throwsA(isA<AnswerValidationException>()),
      );
    });
  });

  group('lesson detail quiz summary', () {
    test('keeps a missing quiz as null and parses a present one', () {
      final LessonDetailModel withoutQuiz = LessonDetailModel.fromData(
        <String, dynamic>{'id': 1, 'title': 'Lesson', 'type': 'article'},
      );
      final LessonDetailModel withQuiz = LessonDetailModel.fromData(
        <String, dynamic>{
          'id': 1,
          'title': 'Lesson',
          'type': 'article',
          'quiz': <String, dynamic>{
            'id': 8,
            'is_blocking': true,
            'has_passed': true,
          },
        },
      );

      expect(withoutQuiz.hasQuiz, isFalse);
      expect(withQuiz.hasQuiz, isTrue);
      expect(withQuiz.quiz?.id, 8);
      expect(withQuiz.isQuizBlocking, isTrue);
      expect(withQuiz.hasPassedQuiz, isTrue);
    });
  });

  group('review helpers', () {
    test('hides a prompt that only repeats the blank sentence', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'fill',
        type: TestQuestionType.fillBlanks,
        prompt: 'Complete {{1}} and {{2}}',
        body: 'Complete {{b_1}} and {{b_2}}',
      );

      expect(question.displayPrompt, 'Complete and');
      expect(question.shouldShowPrompt, isFalse);
    });

    test('keeps a prompt that adds instructions to the blank sentence', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'fill',
        type: TestQuestionType.fillBlanks,
        prompt: 'Choose the right word: {{1}}',
        body: 'The cat {{b_1}}',
      );

      expect(question.shouldShowPrompt, isTrue);
    });

    test('restores a saved answer as touched', () {
      final TestAnswerModel answer = TestAnswerModel.fromSavedJson({
        'option_ids': <String>['o2'],
      });

      expect(answer.optionIds, <String>['o2']);
      expect(answer.isTouched, isTrue);
    });

    test('hasGivenAnswer ignores an empty result payload', () {
      const QuizQuestionResultModel empty = QuizQuestionResultModel(
        questionId: 'q1',
        questionType: TestQuestionType.singleChoice,
      );
      const QuizQuestionResultModel answered = QuizQuestionResultModel(
        questionId: 'q1',
        questionType: TestQuestionType.singleChoice,
        givenAnswer: <String, dynamic>{'option_id': 'o2'},
      );

      expect(empty.hasGivenAnswer, isFalse);
      expect(answered.hasGivenAnswer, isTrue);

      const QuizQuestionResultModel answeredFalse = QuizQuestionResultModel(
        questionId: 'q2',
        questionType: TestQuestionType.trueFalse,
        givenAnswer: <String, dynamic>{'boolean': false},
      );

      expect(answeredFalse.hasGivenAnswer, isTrue);
    });

    test('renders matching solution pairs', () {
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'match',
        questionType: TestQuestionType.matchPairs,
        solution: <String, dynamic>{
          'pairs': <Map<String, dynamic>>[
            <String, dynamic>{'left_text': 'A', 'right_text': '1'},
          ],
        },
      );

      expect(TestSolutionAnswers.of(result), <String>['A → 1']);
    });

    test('reads a solution without a details wrapper', () {
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'order',
        questionType: TestQuestionType.orderSentences,
        solution: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'text': 'First'},
            <String, dynamic>{'text': 'Second'},
          ],
        },
      );

      expect(TestSolutionAnswers.of(result), <String>['First', 'Second']);
    });
  });

  group('session policy', () {
    const AppException forbidden = AppException(
      'session_expired',
      statusCode: 403,
      endsSession: true,
    );

    test('quiz requests can keep a forbidden response local', () {
      expect(
        SessionPolicy.shouldEnd(forbidden, endOnForbidden: false),
        isFalse,
      );
      expect(SessionPolicy.shouldEnd(forbidden, endOnForbidden: true), isTrue);
    });

    test('401 remains a session code', () {
      expect(SessionPolicy.shouldEndStatus(401, endOnForbidden: false), isTrue);
    });
  });
}
