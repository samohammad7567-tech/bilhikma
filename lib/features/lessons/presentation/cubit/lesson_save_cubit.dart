import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_source/saved_lessons_data_source.dart';

part 'lesson_save_state.dart';

class LessonSaveCubit extends Cubit<LessonSaveState> {
  LessonSaveCubit({required this.dataSource})
    : super(LessonSaveState(savedIds: dataSource.savedIds()));

  final SavedLessonsDataSource dataSource;

  bool isSaved(int lessonId) => state.isSaved(lessonId);

  Future<bool> toggle(int lessonId) async {
    final bool isSaved = await dataSource.toggle(lessonId);
    if (isClosed) return isSaved;

    emit(LessonSaveState(savedIds: dataSource.savedIds()));

    return isSaved;
  }

  void refresh() => emit(LessonSaveState(savedIds: dataSource.savedIds()));
}
