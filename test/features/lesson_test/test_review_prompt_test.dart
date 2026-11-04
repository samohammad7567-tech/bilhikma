import 'package:bilhikma/core/enums/test_question_type_enum.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_question_result_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_option_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_question_model.dart';
import 'package:bilhikma/features/lesson_test/presentation/refactor/test_review_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestionResultModel _result(
  TestQuestionType type, {
  Map<String, dynamic> givenAnswer = const <String, dynamic>{},
  Map<String, dynamic> blankResults = const <String, dynamic>{},
}) => QuizQuestionResultModel(
  questionId: 'q',
  questionType: type,
  givenAnswer: givenAnswer,
  blankResults: blankResults,
);

void main() {
  group('review prompt', () {
    test('shows the question text for every question type', () {
      const Map<TestQuestionType, String> prompts = <TestQuestionType, String>{
        TestQuestionType.singleChoice: 'Pick one',
        TestQuestionType.multiChoice: 'Pick many',
        TestQuestionType.mostCorrect: 'Pick the best',
        TestQuestionType.trueFalse: 'True or false?',
        TestQuestionType.orderSentences: 'Order the sentences',
        TestQuestionType.matchPairs: 'Match the pairs',
      };

      for (final MapEntry<TestQuestionType, String> entry in prompts.entries) {
        final TestQuestionModel question = TestQuestionModel(
          id: 'q',
          type: entry.key,
          prompt: entry.value,
        );

        expect(
          TestReviewPrompt.of(result: _result(entry.key), question: question),
          entry.value,
        );
      }
    });

    test('renders the blank sentence with the given word-bank answer', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'q',
        type: TestQuestionType.fillBlanks,
        prompt: 'Choose {{1}} and {{2}}',
        body: 'Choose {{b_1}} and {{b_2}}',
        wordBank: <TestOptionModel>[TestOptionModel(id: 'w1', label: 'right')],
      );

      final String prompt = TestReviewPrompt.of(
        result: _result(
          TestQuestionType.fillBlanks,
          givenAnswer: <String, dynamic>{
            'blanks': <String, dynamic>{'b_1': 'w1'},
          },
        ),
        question: question,
      );

      expect(prompt, 'Choose right and __________');
    });

    test('renders the blank sentence with a typed answer', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'q',
        type: TestQuestionType.typedBlanks,
        prompt: 'Type {{1}}',
        body: 'Type {{b_1}}',
      );

      final String prompt = TestReviewPrompt.of(
        result: _result(
          TestQuestionType.typedBlanks,
          givenAnswer: <String, dynamic>{
            'blanks': <String, dynamic>{'b_1': 'hello'},
          },
        ),
        question: question,
      );

      expect(prompt, 'Type hello');
    });

    test('falls back to blank results and keeps unanswered blanks visible', () {
      const TestQuestionModel question = TestQuestionModel(
        id: 'q',
        type: TestQuestionType.fillBlanks,
        prompt: 'Complete {{1}}',
        body: 'Complete {{b_1}}',
      );

      final String prompt = TestReviewPrompt.of(
        result: _result(
          TestQuestionType.fillBlanks,
          blankResults: <String, dynamic>{
            'b_1': <String, dynamic>{'given_answer': 'w1'},
          },
        ),
        question: question,
      );

      expect(prompt, 'Complete w1');

      expect(
        TestReviewPrompt.of(
          result: _result(TestQuestionType.fillBlanks),
          question: question,
        ),
        'Complete __________',
      );
    });
  });
}
