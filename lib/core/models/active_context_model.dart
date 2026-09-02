import '../enums/enrollment_status_enum.dart';
import '../network/json_reader.dart';

class ActiveContextModel {
  const ActiveContextModel({
    required this.entityId,
    required this.entityName,
    required this.categoryId,
    required this.categoryName,
    this.enrollmentId,
    this.logoUrl,
    this.status,
    this.isArchived = false,
  });

  final int? enrollmentId;
  final int entityId;
  final String entityName;
  final String? logoUrl;
  final int categoryId;
  final String categoryName;
  final EnrollmentStatus? status;

  final bool isArchived;

  factory ActiveContextModel.fromJson(Map<String, dynamic> json) =>
      ActiveContextModel(
        enrollmentId: Json.asOptionalInt(json['enrollment_id']),
        entityId: Json.asInt(json['entity_id']),
        entityName: Json.asString(json['entity_name']),
        logoUrl: Json.asOptionalString(json['logo_url']),
        categoryId: Json.asInt(json['category_id']),
        categoryName: Json.asString(json['category_name']),
        status: EnrollmentStatus.fromJson(json['status']),
        isArchived: Json.asBool(json['is_archived']),
      );
}

class SwitchContextRequestModel {
  const SwitchContextRequestModel({required this.enrollmentId});

  final int enrollmentId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'enrollment_id': enrollmentId,
  };
}
