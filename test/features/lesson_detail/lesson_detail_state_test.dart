import 'package:bilhikma/core/enums/content_type_enum.dart';
import 'package:bilhikma/core/models/lesson_progress_model.dart';
import 'package:bilhikma/features/lesson_detail/data/models/lesson_detail_model.dart';
import 'package:bilhikma/features/lesson_detail/data/models/quiz_summary_model.dart';
import 'package:bilhikma/features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

LessonDetailModel _article({required bool read}) => LessonDetailModel(
  id: 1,
  title: 'Article',
  type: ContentType.article,
  quiz: const QuizSummaryModel(id: 9),
  progress: LessonProgressModel(isCompleted: read, watchedSeconds: 1),
);

LessonDetailState _state({required bool read}) {
  final LessonDetailModel detail = _article(read: read);
  return LessonDetailState(detail: detail, progress: detail.progress);
}

void main() {
  group('LessonDetailState.canStartQuiz', () {
    test('stays closed until the article is confirmed read', () {
      final LessonDetailState state = _state(read: false);

      expect(state.canStartQuiz, isFalse);
    });

    test('opens after a confirmed article read', () {
      final LessonDetailState state = _state(read: true);

      expect(state.canStartQuiz, isTrue);
    });
  });
}
