import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/error_mapper.dart';
import '../models/lesson_test_model.dart';
import '../models/question_start_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/quiz_save_result_model.dart';
import '../quiz_error_mapper.dart';

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

  Future<QuestionStartModel> startQuestion(
    int attemptId,
    String questionId,
  ) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.quizAttemptQuestionStart(attemptId, questionId),
      );
      return QuestionStartModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_question_open_failed');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<QuizSaveResultModel> saveAnswers(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) async {
    try {
      final ApiEnvelope envelope = await client.put(
        ApiEndpoints.quizAttemptAnswers(attemptId),
        data: <String, dynamic>{'answers': answers},
      );
      return QuizSaveResultModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_answers_invalid');
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

  Future<QuizAttemptModel> fetchAttempt(int attemptId) async {
    try {
      return await client.getObject<QuizAttemptModel>(
        ApiEndpoints.quizAttempt(attemptId),
        QuizAttemptModel.fromJson,
      );
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

  Future<int> fetchCategorySubjectId(int contentId) async {
    if (contentId <= 0) return 0;

    try {
      final ApiEnvelope envelope = await client.get(
        ApiEndpoints.contentDetail(contentId),
      );
      final Map<String, dynamic> data = envelope.dataMap;

      final int direct = Json.asInt(data['category_subject_id']);
      if (direct > 0) return direct;

      return Json.asInt(Json.asMap(data['content'])['category_subject_id']);
    } catch (_) {
      return 0;
    }
  }
}
