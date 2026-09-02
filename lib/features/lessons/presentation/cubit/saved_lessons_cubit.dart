import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/data_source/saved_lessons_data_source.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_model.dart';

part 'saved_lessons_state.dart';

class SavedLessonsCubit extends Cubit<SavedLessonsState> {
  SavedLessonsCubit({this.dataSource = const SavedLessonsDataSource()})
    : super(const SavedLessonsState()) {
    loadSaved();
  }

  final SavedLessonsDataSource dataSource;

  Future<void> loadSaved() async {
    emit(state.copyWith(status: SavedLessonsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> selectMediaType(ContentType type) async {
    if (type == state.selectedMediaType) return;

    emit(state.copyWith(selectedMediaType: type));
    await _load();
  }

  Future<void> toggleSaved(int contentId) async {
    await dataSource.toggle(contentId);
    if (isClosed) return;
    await _load();
  }

  Future<void> _load() async {
    try {
      final List<LessonModel> saved = await dataSource.fetchSaved(
        type: state.selectedMediaType,
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          status: SavedLessonsStatus.success,
          allSaved: saved,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(status: SavedLessonsStatus.failure, errorKey: error.key),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SavedLessonsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
