import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/models/active_context_model.dart';
import '../../../../core/models/enrollment_request_model.dart';
import '../../../../core/models/my_enrollments_model.dart';
import '../../../../core/models/public_category_model.dart';
import '../../../../core/models/public_entity_model.dart';

class EnrollmentsDataSource {
  const EnrollmentsDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<MyEnrollmentsModel> fetchMyEnrollments() =>
      client.getObject<MyEnrollmentsModel>(
        ApiEndpoints.myEnrollments,
        MyEnrollmentsModel.fromData,
      );

  Future<ActiveContextModel> fetchActiveContext() =>
      client.getObject<ActiveContextModel>(
        ApiEndpoints.activeContext,
        ActiveContextModel.fromJson,
      );

  Future<ActiveContextModel> switchContext(int enrollmentId) async {
    final ApiEnvelope envelope = await client.put(
      ApiEndpoints.activeContext,
      data: SwitchContextRequestModel(enrollmentId: enrollmentId).toJson(),
    );

    return ActiveContextModel.fromJson(envelope.dataMap);
  }

  Future<List<PublicEntityModel>> fetchPublicEntities() async {
    final ApiEnvelope envelope = await client.get(ApiEndpoints.publicEntities);

    return Json.asList<PublicEntityModel>(
      envelope.dataMap['items'],
      PublicEntityModel.fromJson,
    );
  }

  Future<List<PublicCategoryModel>> fetchPublicCategories(int entityId) async {
    final ApiEnvelope envelope = await client.get(
      ApiEndpoints.publicEntityCategories(entityId),
    );

    return Json.asList<PublicCategoryModel>(
      envelope.dataMap['items'],
      PublicCategoryModel.fromJson,
    );
  }

  Future<EnrollmentRequestModel> apply({
    required int entityId,
    required int categoryId,
  }) async {
    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.enrollments,
      data: ApplyEnrollmentRequestModel(
        entityId: entityId,
        categoryId: categoryId,
      ).toJson(),
    );

    return EnrollmentRequestModel.fromData(envelope.dataMap);
  }
}
