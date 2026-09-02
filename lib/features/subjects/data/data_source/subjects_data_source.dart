import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/models/subject_model.dart';

class SubjectsDataSource {
  const SubjectsDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<List<SubjectModel>> fetchSubjects() async {
    final ApiEnvelope envelope = await client.get(ApiEndpoints.subjects);

    return SubjectModel.listFrom(envelope.dataMap['items']);
  }
}
