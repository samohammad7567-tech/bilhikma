part of 'lesson_test_cubit.dart';

extension LessonTestQuizRestore on LessonTestCubit {
  Duration _remainingOf(QuizAttemptModel attempt, Duration offset) {
    final DateTime? expiresAt = attempt.expiresAt;
    if (expiresAt == null) return Duration.zero;

    final Duration remaining = expiresAt.difference(DateTime.now().add(offset));
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int _resumeIndex(
    QuizAttemptModel attempt,
    Map<String, TestAnswerModel> answers,
  ) {
    final List<TestQuestionModel> questions = attempt.questions;
    if (questions.isEmpty) return 0;

    int lastAnswered = 0;

    for (int index = 0; index < questions.length; index++) {
      final TestQuestionModel question = questions[index];
      final TestAnswerModel? answer = answers[question.id];
      final bool untouchedOrdering =
          question.type == TestQuestionType.orderSentences &&
          !(answer?.isTouched ?? false);
      final bool answered =
          answer != null &&
          answer.isAnswered(question.type) &&
          !untouchedOrdering;

      if (!answered) return index;
      lastAnswered = index;
    }

    return lastAnswered;
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
}
