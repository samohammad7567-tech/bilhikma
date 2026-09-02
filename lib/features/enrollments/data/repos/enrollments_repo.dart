import '../data_source/enrollments_data_source.dart';
import '../../../../core/models/active_context_model.dart';
import '../../../../core/models/enrollment_request_model.dart';
import '../../../../core/models/my_enrollments_model.dart';
import '../../../../core/models/public_category_model.dart';
import '../../../../core/models/public_entity_model.dart';

class EnrollmentsRepo {
  const EnrollmentsRepo({this.dataSource = const EnrollmentsDataSource()});

  final EnrollmentsDataSource dataSource;

  Future<MyEnrollmentsModel> fetchMyEnrollments() =>
      dataSource.fetchMyEnrollments();

  Future<ActiveContextModel> fetchActiveContext() =>
      dataSource.fetchActiveContext();

  Future<ActiveContextModel> switchContext(int enrollmentId) =>
      dataSource.switchContext(enrollmentId);

  Future<List<PublicEntityModel>> fetchPublicEntities() =>
      dataSource.fetchPublicEntities();

  Future<List<PublicCategoryModel>> fetchPublicCategories(int entityId) =>
      dataSource.fetchPublicCategories(entityId);

  Future<EnrollmentRequestModel> apply({
    required int entityId,
    required int categoryId,
  }) => dataSource.apply(entityId: entityId, categoryId: categoryId);
}
