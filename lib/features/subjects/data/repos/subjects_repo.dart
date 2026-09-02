import '../../../../core/models/subject_model.dart';
import '../data_source/subjects_data_source.dart';

class SubjectsRepo {
  const SubjectsRepo({this.dataSource = const SubjectsDataSource()});

  final SubjectsDataSource dataSource;

  Future<List<SubjectModel>> fetchSubjects() => dataSource.fetchSubjects();
}
