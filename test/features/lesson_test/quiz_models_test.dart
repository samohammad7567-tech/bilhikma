import 'package:bilhikma/core/enums/assessment_type_enum.dart';
import 'package:bilhikma/core/enums/blank_input_mode_enum.dart';
import 'package:bilhikma/core/enums/test_question_type_enum.dart';
import 'package:bilhikma/core/localization/lang_keys.dart';
import 'package:bilhikma/core/network/session_policy.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/lesson_test/data/models/lesson_test_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/question_start_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_attempt_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_question_result_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_answer_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_match_item_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_option_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_question_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_sentence_model.dart';
import 'package:bilhikma/features/lesson_test/presentation/refactor/quiz_review_answer.dart';
import 'package:bilhikma/features/lesson_test/presentation/refactor/test_given_answers.dart';
import 'package:bilhikma/features/lesson_test/presentation/refactor/test_solution_answers.dart';
import 'package:bilhikma/features/lesson_detail/data/models/lesson_detail_model.dart';
import 'package:easy_localization/easy_localization.dart';
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

    test('parses an open attempt so the quiz can be resumed', () {
      final LessonTestModel quiz = LessonTestModel.fromJson(<String, dynamic>{
        'id': 2,
        'content_id': 11,
        'title': 'Quiz',
        'question_count': 5,
        'attempts_used': 3,
        'attempts_left': 0,
        'has_open_attempt': true,
        'open_attempt': <String, dynamic>{
          'id': 81,
          'attempt_no': 2,
          'started_at': '2099-01-01T10:00:00Z',
          'expires_at': '2099-01-01T10:30:00Z',
          'answered_count': 2,
          'total_questions': 5,
          'remaining_seconds': 1200,
        },
      });

      expect(quiz.hasOpenAttempt, isTrue);
      expect(quiz.openAttempt?.id, 81);
      expect(quiz.openAttempt?.attemptNo, 2);
      expect(quiz.openAttempt?.answeredCount, 2);
      expect(quiz.openAttempt?.remainingSeconds, 1200);
      expect(quiz.openAttempt?.hasExpired, isFalse);
    });
  });

  group('assessment type', () {
    test('defaults to lesson_quiz when the type is absent', () {
      final LessonTestModel quiz = LessonTestModel.fromJson(<String, dynamic>{
        'id': 2,
        'title': 'Quiz',
      });

      expect(quiz.type, AssessmentType.lessonQuiz);
      expect(quiz.isSupported, isTrue);
    });

    test('keeps lesson_quiz supported', () {
      final LessonTestModel quiz = LessonTestModel.fromJson(<String, dynamic>{
        'id': 2,
        'title': 'Quiz',
        'type': 'lesson_quiz',
      });

      expect(quiz.type, AssessmentType.lessonQuiz);
      expect(quiz.isSupported, isTrue);
    });

    test('parses midterm and final_exam as unsupported', () {
      for (final String type in <String>['midterm', 'final_exam']) {
        final LessonTestModel quiz = LessonTestModel.fromJson(
          <String, dynamic>{'id': 2, 'title': 'Assessment', 'type': type},
        );

        expect(quiz.isSupported, isFalse);
      }
    });

    test('treats an unknown explicit type as unsupported', () {
      final LessonTestModel quiz = LessonTestModel.fromJson(<String, dynamic>{
        'id': 2,
        'title': 'Assessment',
        'type': 'placement_test',
      });

      expect(quiz.type, AssessmentType.unknown);
      expect(quiz.isSupported, isFalse);
    });
  });

  group('attempt assessment alias', () {
    test('reads assessment_id and falls back to quiz_id', () {
      final QuizAttemptModel fromAssessment = QuizAttemptModel.fromJson(
        <String, dynamic>{'id': 5, 'assessment_id': 12},
      );
      final QuizAttemptModel fromLegacy = QuizAttemptModel.fromJson(
        <String, dynamic>{'id': 5, 'quiz_id': 12},
      );

      expect(fromAssessment.quizId, 12);
      expect(fromLegacy.quizId, 12);
    });

    test('prefers assessment_id when both aliases are present', () {
      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{'id': 5, 'assessment_id': 12, 'quiz_id': 99},
      );

      expect(attempt.quizId, 12);
    });

    test('ignores unknown response fields', () {
      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{
          'id': 5,
          'assessment_id': 12,
          'unknown_future_field': <String, dynamic>{'a': 1},
        },
      );

      expect(attempt.id, 5);
      expect(attempt.quizId, 12);
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

    test('parses server clock and per-question timer state', () {
      final Map<String, dynamic> questionJson = <String, dynamic>{
        'question_id': 38,
        'question_text': 'Pick the red card',
        'question_type': 'mcq_single',
        'score': 2,
        'default_time_seconds': 45,
        'options': <String, dynamic>{
          'details': <String, dynamic>{
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'id': 'red', 'text': 'Red'},
            ],
          },
        },
        'timer': <String, dynamic>{
          'enabled': true,
          'started_at': '2026-11-04T11:35:09+00:00',
          'expires_at': '2026-11-04T11:35:54+00:00',
          'seconds_left': 40,
          'has_expired': false,
          'can_answer': true,
        },
      };

      final TestQuestionModel question = TestQuestionModel.fromJson(
        questionJson,
      );

      expect(question.timeLimit, const Duration(seconds: 45));
      expect(question.initialTimer?.isTimed, isTrue);
      expect(question.initialTimer?.secondsLeft, 40);

      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{
          'id': 171,
          'quiz_id': 2,
          'student_id': 9,
          'attempt_no': 1,
          'server_now': '2026-11-04T11:35:14+00:00',
          'question_timing_enabled': true,
          'answers': <Map<String, dynamic>>[questionJson],
        },
      );

      expect(attempt.serverNow?.toUtc(), DateTime.utc(2026, 11, 4, 11, 35, 14));
      expect(attempt.questionTimingEnabled, isTrue);
      expect(attempt.questionTimers['38']?.canAnswer, isTrue);
    });

    test('detects rich prompts from the question format', () {
      final TestQuestionModel topLevel =
          TestQuestionModel.fromJson(<String, dynamic>{
            'question_id': 41,
            'question_text': '**Bold** prompt',
            'question_type': 'mcq_single',
            'question_format': 'markdown',
          });
      final TestQuestionModel nested = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 42,
          'question_text': 'Plain prompt',
          'question_type': 'mcq_single',
          'options': <String, dynamic>{'question_format': 'rich_text'},
        },
      );

      expect(topLevel.isRichPrompt, isTrue);
      expect(nested.isRichPrompt, isTrue);
    });

    test('parses a question start response with the saved answer', () {
      final QuestionStartModel start = QuestionStartModel.fromJson(
        <String, dynamic>{
          'attempt_id': 171,
          'question_id': 38,
          'server_now': '2026-11-04T11:35:14+00:00',
          'attempt_expires_at': null,
          'timer': <String, dynamic>{
            'enabled': true,
            'started_at': '2026-11-04T11:35:09+00:00',
            'expires_at': '2026-11-04T11:35:54+00:00',
            'seconds_left': 40,
            'has_expired': false,
            'can_answer': true,
          },
          'saved_answer': <String, dynamic>{'option_id': 'red'},
        },
      );

      expect(start.timer.canAnswer, isTrue);
      expect(start.savedAnswer?['option_id'], 'red');
      expect(start.attemptExpiresAt, isNull);
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

    test('reads option images and feedback for review items', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'q1',
        type: TestQuestionType.singleChoice,
        prompt: '',
        options: <TestOptionModel>[TestOptionModel(id: 'o1', label: 'One')],
      );
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 'q1',
          'question_type': 'mcq_single',
          'given_answer': <String, dynamic>{'option_id': 'o1'},
          'solution': <String, dynamic>{
            'details': <String, dynamic>{
              'options': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'o1',
                  'text': 'One',
                  'image_path': 'qa-quiz-fields/one.png',
                  'feedback': 'Well done',
                  'is_correct': true,
                },
              ],
            },
          },
        },
      );

      final QuizReviewAnswer given = TestGivenAnswers.itemsOf(
        result,
        question: question,
      ).single;
      final QuizReviewAnswer solution = TestSolutionAnswers.itemsOf(
        result,
        question: question,
      ).single;

      expect(given.text, 'One');
      expect(given.feedback, 'Well done');
      expect(
        given.imageUrl,
        'https://bilhikma.tech/storage/qa-quiz-fields/one.png',
      );
      expect(solution.feedback, 'Well done');
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

    test('shows every correct choice when a multi answer is wrong', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'multi',
        type: TestQuestionType.multiChoice,
        prompt: '',
        options: <TestOptionModel>[
          TestOptionModel(id: 'o1', label: 'Wrong'),
          TestOptionModel(id: 'o2', label: 'Right'),
        ],
      );
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'multi',
        questionType: TestQuestionType.multiChoice,
        isCorrect: false,
        givenAnswer: <String, dynamic>{
          'option_ids': <String>['o1'],
        },
        solution: <String, dynamic>{
          'details': <String, dynamic>{
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'id': 'o1', 'is_correct': false},
              <String, dynamic>{'id': 'o2', 'is_correct': true},
            ],
          },
        },
      );

      expect(TestSolutionAnswers.of(result, question: question), <String>[
        'Right',
      ]);
      expect(TestGivenAnswers.of(result, question: question), <String>[
        'Wrong',
      ]);
    });

    test('reads correct option ids without per-option flags', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'multi',
        type: TestQuestionType.multiChoice,
        prompt: '',
        options: <TestOptionModel>[
          TestOptionModel(id: 'o1', label: 'First'),
          TestOptionModel(id: 'o2', label: 'Second'),
        ],
      );
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'multi',
        questionType: TestQuestionType.multiChoice,
        solution: <String, dynamic>{
          'details': <String, dynamic>{
            'correct_option_ids': <String>['o1', 'o2'],
          },
        },
      );

      expect(TestSolutionAnswers.of(result, question: question), <String>[
        'First',
        'Second',
      ]);
    });

    test('reads matching maps for solution and given answer', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'match',
        type: TestQuestionType.matchPairs,
        prompt: '',
        leftItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'l1', text: 'A'),
        ],
        rightItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'r1', text: '1'),
        ],
      );
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'match',
        questionType: TestQuestionType.matchPairs,
        givenAnswer: <String, dynamic>{
          'matches': <String, dynamic>{'r1': 'l1'},
        },
        solution: <String, dynamic>{
          'details': <String, dynamic>{
            'matches': <String, dynamic>{'r1': 'l1'},
          },
        },
      );

      expect(TestSolutionAnswers.of(result, question: question), <String>[
        'A → 1',
      ]);
      expect(TestGivenAnswers.of(result, question: question), <String>[
        'A → 1',
      ]);
    });

    test('resolves ordering ids for solution and given answer', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'order',
        type: TestQuestionType.orderSentences,
        prompt: '',
        sentences: <TestSentenceModel>[
          TestSentenceModel(id: 's1', text: 'First'),
          TestSentenceModel(id: 's2', text: 'Second'),
        ],
      );
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'order',
        questionType: TestQuestionType.orderSentences,
        givenAnswer: <String, dynamic>{
          'order': <String>['s1', 's2'],
        },
        solution: <String, dynamic>{
          'details': <String, dynamic>{
            'correct_order': <String>['s2', 's1'],
          },
        },
      );

      expect(TestSolutionAnswers.of(result, question: question), <String>[
        'Second',
        'First',
      ]);
      expect(TestGivenAnswers.of(result, question: question), <String>[
        'First',
        'Second',
      ]);
    });

    test('reads typed blank answers stored as maps', () {
      const QuizQuestionResultModel result = QuizQuestionResultModel(
        questionId: 'typed',
        questionType: TestQuestionType.typedBlanks,
        solution: <String, dynamic>{
          'details': <String, dynamic>{
            'blanks': <String, dynamic>{
              'b1': <String, dynamic>{
                'accepted': <String>['cat'],
              },
            },
          },
        },
      );

      expect(TestSolutionAnswers.of(result), <String>['cat']);
    });

    test('reads true or false given and correct answer from the result', () {
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 23,
          'question_type': 'true_false',
          'question_text': 'الغيبة من أركان الإسلام',
          'options': <String, dynamic>{'correct_answer': false},
          'selected_boolean': false,
          'is_correct': true,
        },
      );

      expect(TestGivenAnswers.of(result), <String>[LangKeys.quizFalse.tr()]);
      expect(TestSolutionAnswers.of(result), <String>[LangKeys.quizFalse.tr()]);
    });

    test('reads the answer status of a partially correct answer', () {
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 39,
          'question_type': 'mcq_multiple',
          'is_correct': false,
          'answer_status': 'partial',
          'awarded_score': 2,
          'score': 4,
          'given_answer': <String, dynamic>{
            'option_ids': <String>['four'],
          },
        },
      );

      expect(result.isCorrect, isFalse);
      expect(result.answerStatus, 'partial');
      expect(result.awardedScore, 2);
    });

    test(
      'infers the opposite true or false answer when the choice is wrong',
      () {
        final QuizQuestionResultModel result =
            QuizQuestionResultModel.fromJson(<String, dynamic>{
              'question_id': 24,
              'question_type': 'true_false',
              'selected_boolean': true,
              'is_correct': false,
            });

        expect(TestGivenAnswers.of(result), <String>[LangKeys.quizTrue.tr()]);
        expect(TestSolutionAnswers.of(result), <String>[
          LangKeys.quizFalse.tr(),
        ]);
      },
    );

    test('reads dropdown blanks using choice ids from the real payload', () {
      final TestQuestionModel question = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'question_text': 'أول أركان الإسلام {{1}}',
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'blanks': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'b_1',
                  'blank_index': 1,
                  'choices': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'c_2', 'text': 'الصلاة'},
                    <String, dynamic>{'id': 'c_1', 'text': 'الشهادتان'},
                  ],
                },
              ],
              'blank_input_mode': 'dropdown',
            },
          },
        },
      );
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'given_answer': <String, dynamic>{
            'blanks': <String, dynamic>{'b_1': 'c_2'},
          },
          'solution': <String, dynamic>{
            'details': <String, dynamic>{
              'blanks': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'b_1',
                  'choices': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'id': 'c_1',
                      'text': 'الشهادتان',
                      'is_correct': true,
                    },
                    <String, dynamic>{
                      'id': 'c_2',
                      'text': 'الصلاة',
                      'is_correct': false,
                    },
                  ],
                },
              ],
            },
          },
        },
      );

      expect(TestGivenAnswers.of(result, question: question), <String>[
        'الصلاة',
      ]);
      expect(TestSolutionAnswers.of(result, question: question), <String>[
        'الشهادتان',
      ]);
    });

    test('reads blank given answers from blank results', () {
      final TestQuestionModel question = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'question_text': 'أول أركان الإسلام {{1}}',
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'blanks': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'b_1',
                  'blank_index': 1,
                  'choices': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'c_2', 'text': 'الصلاة'},
                    <String, dynamic>{'id': 'c_1', 'text': 'الشهادتان'},
                  ],
                },
              ],
              'blank_input_mode': 'dropdown',
            },
          },
        },
      );
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'blank_results': <String, dynamic>{
            'b_1': <String, dynamic>{'given_answer': 'c_2'},
          },
        },
      );

      expect(TestGivenAnswers.of(result, question: question), <String>[
        'الصلاة',
      ]);
      expect(result.hasGivenAnswer, isTrue);
    });

    test('normalizes list shaped blank results and resolves the answer', () {
      final TestQuestionModel question = TestQuestionModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'question_text': 'أول أركان الإسلام {{1}}',
          'options': <String, dynamic>{
            'details': <String, dynamic>{
              'blanks': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'b_1',
                  'blank_index': 1,
                  'choices': <Map<String, dynamic>>[
                    <String, dynamic>{'id': 'c_2', 'text': 'الصلاة'},
                  ],
                },
              ],
              'blank_input_mode': 'dropdown',
            },
          },
        },
      );
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 14,
          'question_type': 'fill_blank_choice',
          'blank_results': <Map<String, dynamic>>[
            <String, dynamic>{'blank_id': 'b_1', 'given_answer': 'c_2'},
          ],
        },
      );

      expect(TestGivenAnswers.of(result, question: question), <String>[
        'الصلاة',
      ]);
    });

    test('reads matching given answers from component results', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'match',
        type: TestQuestionType.matchPairs,
        prompt: '',
        leftItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'l1', text: 'A'),
        ],
        rightItems: <TestMatchItemModel>[
          TestMatchItemModel(id: 'r1', text: '1'),
        ],
      );
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 'match',
          'question_type': 'matching',
          'component_results': <String, dynamic>{'r1': 'l1'},
        },
      );

      expect(TestGivenAnswers.of(result, question: question), <String>[
        'A → 1',
      ]);
      expect(result.hasGivenAnswer, isTrue);
    });

    test('drops distractor pairs from the matching solution', () {
      final QuizQuestionResultModel result = QuizQuestionResultModel.fromJson(
        <String, dynamic>{
          'question_id': 16,
          'question_type': 'matching',
          'solution': <String, dynamic>{
            'details': <String, dynamic>{
              'pairs': <Map<String, dynamic>>[
                <String, dynamic>{
                  'left_text': 'الفجر',
                  'right_text': 'ركعتان',
                  'is_distractor': false,
                },
                <String, dynamic>{
                  'left_text': null,
                  'right_text': 'خمس',
                  'is_distractor': true,
                },
              ],
            },
          },
        },
      );

      expect(TestSolutionAnswers.of(result), <String>['الفجر → ركعتان']);
    });

    test('keeps an unanswered result empty', () {
      final QuizQuestionResultModel result =
          QuizQuestionResultModel.fromJson(<String, dynamic>{
            'question_id': 25,
            'question_type': 'true_false',
            'selected_boolean': null,
            'answer_text': null,
            'is_correct': false,
          });

      expect(result.givenAnswer, isEmpty);
      expect(result.hasGivenAnswer, isFalse);
    });

    test('exposes released solutions for the result review gate', () {
      final QuizAttemptModel attempt = QuizAttemptModel.fromJson(
        <String, dynamic>{
          'id': 3,
          'answers': <Map<String, dynamic>>[
            <String, dynamic>{
              'question_id': 21,
              'question_type': 'mcq_single',
              'is_correct': false,
              'given_answer': <String, dynamic>{'option_id': 'o_2'},
              'solution': <String, dynamic>{
                'details': <String, dynamic>{
                  'options': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'id': 'o_1',
                      'text': 'الصلاة',
                      'is_correct': true,
                    },
                  ],
                },
              },
            },
          ],
        },
      );

      expect(attempt.hasSolutions, isTrue);
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
