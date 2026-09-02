import '../enums/enrollment_status_enum.dart';
import '../network/json_reader.dart';

class ApplyEnrollmentRequestModel {
  const ApplyEnrollmentRequestModel({
    required this.entityId,
    required this.categoryId,
  });

  final int entityId;

  final int categoryId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'entity_id': entityId,
    'category_id': categoryId,
  };
}

class EnrollmentRequestModel {
  const EnrollmentRequestModel({
    required this.id,
    required this.entityName,
    required this.categoryName,
    this.status,
    this.isCurrent = false,
  });

  final int id;
  final String entityName;
  final String categoryName;

  final EnrollmentStatus? status;

  final bool isCurrent;

  factory EnrollmentRequestModel.fromData(Map<String, dynamic> data) =>
      EnrollmentRequestModel(
        id: Json.asInt(data['id']),
        entityName: Json.asString(data['entity_name']),
        categoryName: Json.asString(data['category_name']),
        status: EnrollmentStatus.fromJson(data['status']),
        isCurrent: Json.asBool(data['is_current']),
      );
}
