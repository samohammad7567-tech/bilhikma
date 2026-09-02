import '../data_source/lesson_test_data_source.dart';
import '../models/lesson_test_model.dart';
import '../models/test_answer_model.dart';
import '../models/test_result_model.dart';

class LessonTestRepo {
  const LessonTestRepo({this.dataSource = const LessonTestDataSource()});

  final LessonTestDataSource dataSource;

  Future<LessonTestModel> fetchTest({required String lessonId}) =>
      dataSource.fetchTest(lessonId: lessonId);

  Future<TestResultModel> submitAttempt({
    required LessonTestModel test,
    required Map<String, TestAnswerModel> answers,
  }) => dataSource.submitAttempt(test: test, answers: answers);
}
