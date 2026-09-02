import '../../../../core/utils/error_mapper.dart';
import '../models/lesson_test_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_result_model.dart';
import 'lesson_test_mock.dart';
import 'test_answer_grader.dart';

class LessonTestDataSource {
  const LessonTestDataSource();

  Future<LessonTestModel> fetchTest({required String lessonId}) async {
    try {
      return LessonTestModel.fromJson(LessonTestMock.test(lessonId));
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }

  Future<TestResultModel> submitAttempt({
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
