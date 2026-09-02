import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/models/subject_model.dart';
import '../../data/repos/subjects_repo.dart';

part 'subjects_state.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit({this.repo = const SubjectsRepo()})
    : super(const SubjectsState()) {
    loadSubjects();
  }

  final SubjectsRepo repo;

  Future<void> loadSubjects() async {
    emit(state.copyWith(status: SubjectsStatus.loading));

    try {
      final List<SubjectModel> subjects = await repo.fetchSubjects();
      emit(state.copyWith(status: SubjectsStatus.success, subjects: subjects));
    } catch (error) {
      emit(
        state.copyWith(
          status: SubjectsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final List<SubjectModel> subjects = await repo.fetchSubjects();
      emit(state.copyWith(status: SubjectsStatus.success, subjects: subjects));
    } catch (error) {
      emit(state.copyWith(errorKey: ErrorMapper.map(error)));
    }
  }
}
