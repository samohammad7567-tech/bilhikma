import '../data_source/subject_content_data_source.dart';
import '../../../../core/models/subject_content_model.dart';

class SubjectContentRepo {
  const SubjectContentRepo({
    this.dataSource = const SubjectContentDataSource(),
  });

  final SubjectContentDataSource dataSource;

  Future<SubjectContentModel> fetchSubject(int categorySubjectId) =>
      dataSource.fetchSubject(categorySubjectId);
}
