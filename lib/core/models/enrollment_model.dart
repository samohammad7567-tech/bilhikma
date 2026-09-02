import '../enums/enrollment_status_enum.dart';
import '../network/json_reader.dart';

class EnrollmentModel {
  const EnrollmentModel({
    required this.id,
    required this.entityId,
    required this.entityName,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.isCurrent,
    this.rejectionReason,
  });

  final int id;
  final int entityId;
  final String entityName;
  final int categoryId;
  final String categoryName;
  final EnrollmentStatus status;
  final bool isCurrent;
  final String? rejectionReason;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        id: Json.asInt(json['id']),
        entityId: Json.asInt(json['entity_id']),
        entityName: Json.asString(json['entity_name']),
        categoryId: Json.asInt(json['category_id']),
        categoryName: Json.asString(json['category_name']),
        status:
            EnrollmentStatus.fromJson(json['status']) ??
            EnrollmentStatus.pending,
        isCurrent: Json.asBool(json['is_current']),
        rejectionReason: Json.asOptionalString(json['rejection_reason']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'entity_id': entityId,
    'entity_name': entityName,
    'category_id': categoryId,
    'category_name': categoryName,
    'status': status.key,
    'is_current': isCurrent,
    'rejection_reason': rejectionReason,
  };
}
