import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/error_mapper.dart';
import '../models/lesson_test_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_result_model.dart';
import '../quiz_error_mapper.dart';
import 'lesson_test_mock.dart';
import 'test_answer_grader.dart';

class LessonTestDataSource {
  const LessonTestDataSource({
    this.client = const ApiClient(endSessionOnForbidden: false),
  });

  final ApiClient client;

  Future<LessonTestModel> fetchQuiz(int contentId) async {
    try {
      return await client.getObject<LessonTestModel>(
        ApiEndpoints.contentQuiz(contentId),
        LessonTestModel.fromJson,
      );
    } on FormatException {
      throw const AppException('quiz_unavailable');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<QuizAttemptModel> startAttempt(int quizId) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.quizAttempts(quizId),
      );
      return QuizAttemptModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_unsupported_question');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<QuizAttemptModel> submitAttempt(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.quizAttemptSubmit(attemptId),
        data: <String, dynamic>{'answers': answers},
      );
      return QuizAttemptModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_unavailable');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<List<QuizAttemptModel>> fetchMyAttempts(int quizId) async {
    try {
      final ApiEnvelope envelope = await client.get(
        ApiEndpoints.quizMyAttempts(quizId),
      );
      final Object? data = envelope.data;
      final List<Map<String, dynamic>> items = data is List
          ? Json.asMapList(data)
          : Json.asMapList(Json.asMap(data)['items']);

      return items.map(QuizAttemptModel.fromJson).toList(growable: false);
    } on FormatException {
      throw const AppException('quiz_unavailable');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  @Deprecated('Legacy screen only; remove with the mock in Phase 7.')
  Future<LessonTestModel> fetchTest({required String lessonId}) async {
    try {
      return LessonTestModel.fromJson(LessonTestMock.test(lessonId));
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  @Deprecated('Legacy screen only; remove with the client grader in Phase 7.')
  Future<TestResultModel> submitLegacyAttempt({
    required LessonTestModel test,
    required Map<String, TestAnswerModel> answers,
  }) async {
    try {
      final TestResultCounts counts = TestAnswerGrader.count(
        test: test,
        answers: answers,
      );

      return TestResultModel(
        correctCount: counts.correct,
        totalCount: counts.total,
        passPercent: test.passPercent,
        retryAfterDays: test.retryAfterDays,
      );
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }
}
