import '../data_source/lesson_test_data_source.dart';
import '../models/lesson_test_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_result_model.dart';

class LessonTestRepo {
  const LessonTestRepo({this.dataSource = const LessonTestDataSource()});

  final LessonTestDataSource dataSource;

  Future<LessonTestModel> fetchQuiz(int contentId) =>
      dataSource.fetchQuiz(contentId);

  Future<QuizAttemptModel> startAttempt(int quizId) =>
      dataSource.startAttempt(quizId);

  Future<QuizAttemptModel> submitAttempt(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) => dataSource.submitAttempt(attemptId, answers);

  Future<List<QuizAttemptModel>> fetchMyAttempts(int quizId) =>
      dataSource.fetchMyAttempts(quizId);

  @Deprecated('Legacy screen only; remove with the mock in Phase 7.')
  Future<LessonTestModel> fetchTest({required String lessonId}) =>
      dataSource.fetchTest(lessonId: lessonId);

  @Deprecated('Legacy screen only; remove with the client grader in Phase 7.')
  Future<TestResultModel> submitLegacyAttempt({
    required LessonTestModel test,
    required Map<String, TestAnswerModel> answers,
  }) => dataSource.submitLegacyAttempt(test: test, answers: answers);
}
