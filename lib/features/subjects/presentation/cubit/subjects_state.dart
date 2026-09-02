part of 'subjects_cubit.dart';

enum SubjectsStatus { initial, loading, success, failure }

final class SubjectsState {
  const SubjectsState({
    this.status = SubjectsStatus.initial,
    this.subjects,
    this.errorKey,
  });

  final SubjectsStatus status;
  final List<SubjectModel>? subjects;
  final String? errorKey;

  bool get isFirstLoad => status == SubjectsStatus.loading && subjects == null;

  bool get hasFailed => status == SubjectsStatus.failure && subjects == null;

  List<SubjectModel> get visibleSubjects => subjects ?? const <SubjectModel>[];

  SubjectsState copyWith({
    SubjectsStatus? status,
    List<SubjectModel>? subjects,
    String? errorKey,
  }) => SubjectsState(
    status: status ?? this.status,
    subjects: subjects ?? this.subjects,
    errorKey: errorKey,
  );
}
