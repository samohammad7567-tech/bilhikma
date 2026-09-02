import '../network/json_reader.dart';
import 'enrollment_node_model.dart';

class EnrollmentEntityModel {
  const EnrollmentEntityModel({
    required this.entityId,
    required this.entityName,
    this.logoUrl,
    this.isActiveEntity = false,
    this.tree = const <EnrollmentNodeModel>[],
  });

  final int entityId;
  final String entityName;
  final String? logoUrl;

  final bool isActiveEntity;
  final List<EnrollmentNodeModel> tree;

  bool get hasClasses => tree.isNotEmpty;

  List<EnrollmentNodeModel> get selectableClasses => <EnrollmentNodeModel>[
    for (final EnrollmentNodeModel root in tree)
      ...root.flattened().where(
        (EnrollmentNodeModel node) => node.isSelectable,
      ),
  ];

  factory EnrollmentEntityModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentEntityModel(
        entityId: Json.asInt(json['entity_id']),
        entityName: Json.asString(json['entity_name']),
        logoUrl: Json.asOptionalString(json['logo_url']),
        isActiveEntity: Json.asBool(json['is_active_entity']),
        tree: Json.asList<EnrollmentNodeModel>(
          json['tree'],
          EnrollmentNodeModel.fromJson,
        ),
      );
}
