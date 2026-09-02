import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/paginated_result.dart';
import '../../../../core/network/pagination_meta.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/subject_content_model.dart';
import '../../../subject_content/data/repos/subject_content_repo.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/lessons_filter.dart';
import '../../data/repos/lessons_repo.dart';

part 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({
    required this.categorySubjectId,
    this.repo = const LessonsRepo(),
    this.subjectRepo = const SubjectContentRepo(),
  }) : super(const LessonsState()) {
    load();
  }

  final int categorySubjectId;

  final LessonsRepo repo;
  final SubjectContentRepo subjectRepo;

  Future<void> load() async {
    emit(state.copyWith(status: LessonsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> selectType(ContentType type) async {
    if (type == state.selectedType) return;

    emit(state.copyWith(selectedType: type, status: LessonsStatus.loading));
    await _loadLessons(type);
  }

  Future<void> _load() async {
    try {
      final SubjectContentModel subject = await subjectRepo.fetchSubject(
        categorySubjectId,
      );
      if (isClosed) return;

      emit(state.copyWith(subject: subject));
      await _loadLessons(state.selectedType);
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LessonsStatus.failure, errorKey: error.key));
    }
  }

  Future<void> _loadLessons(ContentType type) async {
    try {
      final PaginatedResult<LessonModel> page = await repo.fetchLessons(
        LessonsFilter(categorySubjectId: categorySubjectId, type: type),
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          status: LessonsStatus.success,
          lessons: page.items,
          meta: page.meta,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LessonsStatus.failure, errorKey: error.key));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LessonsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final PaginatedResult<LessonModel> page = await repo.fetchLessons(
        LessonsFilter(
          categorySubjectId: categorySubjectId,
          type: state.selectedType,
          page: state.meta.nextPage,
        ),
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          lessons: <LessonModel>[...state.lessons, ...page.items],
          meta: page.meta,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoadingMore: false, errorKey: ErrorMapper.map(error)),
      );
    }
  }
}
