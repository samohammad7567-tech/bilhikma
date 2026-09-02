import '../models/lesson_test_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_blank_model.dart';
import '../models/test_pair_model.dart';
import '../models/test_question_model.dart';
import '../../../../core/enums/test_question_type_enum.dart';

class TestAnswerGrader {
  TestAnswerGrader._();

  static TestResultCounts count({
    required LessonTestModel test,
    required Map<String, TestAnswerModel> answers,
  }) {
    int correct = 0;

    for (final TestQuestionModel question in test.questions) {
      if (isCorrect(question: question, answer: answers[question.id])) {
        correct += 1;
      }
    }

    return TestResultCounts(correct: correct, total: test.questionCount);
  }

  static bool isCorrect({
    required TestQuestionModel question,
    TestAnswerModel? answer,
  }) {
    if (answer == null) return false;

    switch (question.type) {
      case TestQuestionType.singleChoice:
      case TestQuestionType.trueFalse:
        return _singlePick(answer, question.correctOptionIds);

      case TestQuestionType.mostCorrect:
        final String? mostCorrect = question.mostCorrectOptionId;
        return mostCorrect != null &&
            _singlePick(answer, <String>[mostCorrect]);

      case TestQuestionType.multiChoice:
        return _sameSet(answer.optionIds, question.correctOptionIds);

      case TestQuestionType.fillBlanks:
        return _everyBlank(
          question,
          (TestBlankModel blank) =>
              blank.correctOptionId != null &&
              answer.blankValue(blank.id) == blank.correctOptionId,
        );

      case TestQuestionType.typedBlanks:
        return _everyBlank(
          question,
          (TestBlankModel blank) =>
              _matchesTyped(blank, answer.blankValue(blank.id)),
        );

      case TestQuestionType.matchPairs:
        return question.pairs.isNotEmpty &&
            question.pairs.every(
              (TestPairModel pair) => answer.matchOf(pair.id) == pair.id,
            );

      case TestQuestionType.orderSentences:
        return _sameOrder(answer.order, question.correctSentenceIds);
    }
  }

  static String normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[ً-ْـٰ]'), '')
      .replaceAll(RegExp('[آأإٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'\s+'), ' ');

  static bool _singlePick(TestAnswerModel answer, List<String> accepted) =>
      answer.optionIds.length == 1 &&
      accepted.contains(answer.optionIds.single);

  static bool _everyBlank(
    TestQuestionModel question,
    bool Function(TestBlankModel blank) check,
  ) => question.blanks.isNotEmpty && question.blanks.every(check);

  static bool _matchesTyped(TestBlankModel blank, String? value) {
    if (value == null || blank.acceptedAnswers.isEmpty) return false;
    final String typed = normalize(value);

    return blank.acceptedAnswers.any(
      (String accepted) => normalize(accepted) == typed,
    );
  }

  static bool _sameSet(List<String> picked, List<String> expected) =>
      expected.isNotEmpty &&
      picked.length == expected.length &&
      picked.toSet().containsAll(expected);

  static bool _sameOrder(List<String> picked, List<String> expected) {
    if (expected.isEmpty || picked.length != expected.length) return false;

    for (int index = 0; index < expected.length; index++) {
      if (picked[index] != expected[index]) return false;
    }
    return true;
  }
}

class TestResultCounts {
  const TestResultCounts({required this.correct, required this.total});

  final int correct;
  final int total;
}
