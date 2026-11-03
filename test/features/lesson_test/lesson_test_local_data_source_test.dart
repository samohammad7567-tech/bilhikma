import 'package:bilhikma/core/utils/cache_util.dart';
import 'package:bilhikma/features/lesson_test/data/data_source/lesson_test_local_data_source.dart';
import 'package:bilhikma/features/lesson_test/data/models/test_answer_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LessonTestLocalDataSource', () {
    test('round-trips saved answers for the same attempt', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await CacheUtil.init();

      const LessonTestLocalDataSource store = LessonTestLocalDataSource();
      final DateTime now = DateTime.now();

      await store.write(
        LessonTestSavedAnswersModel(
          attemptId: 7,
          quizId: 10,
          updatedAt: now,
          answers: <String, TestAnswerModel>{
            'q1': const TestAnswerModel(
              optionIds: <String>['o2'],
              isTouched: true,
            ),
          },
        ),
      );

      final LessonTestSavedAnswersModel? saved = store.read(7);

      expect(saved?.attemptId, 7);
      expect(saved?.quizId, 10);
      expect(saved?.answers['q1']?.optionIds, <String>['o2']);
      expect(saved?.answers['q1']?.isTouched, isTrue);

      store.clear(7);

      expect(store.read(7), isNull);
    });

    test('ignores a corrupt cache entry', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await CacheUtil.init();
      await CacheUtil.setString(
        key: 'lesson_test_answers_8',
        value: '{not json',
      );

      const LessonTestLocalDataSource store = LessonTestLocalDataSource();

      expect(store.read(8), isNull);
    });
  });
}
