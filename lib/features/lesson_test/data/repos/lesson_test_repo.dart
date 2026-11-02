import '../data_source/lesson_test_data_source.dart';
import '../models/lesson_test_model.dart';
import '../models/quiz_attempt_model.dart';

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
}
