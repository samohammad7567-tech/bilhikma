import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/subject_content_model.dart';

class SubjectContentDataSource {
  const SubjectContentDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<SubjectContentModel> fetchSubject(int categorySubjectId) =>
      client.getObject<SubjectContentModel>(
        ApiEndpoints.subject(categorySubjectId),
        SubjectContentModel.fromData,
      );
}
