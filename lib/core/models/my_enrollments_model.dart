import '../network/json_reader.dart';
import 'enrollment_entity_model.dart';
import 'enrollment_node_model.dart';

class MyEnrollmentsModel {
  const MyEnrollmentsModel({
    this.activeEnrollmentId,
    this.entities = const <EnrollmentEntityModel>[],
  });

  final int? activeEnrollmentId;
  final List<EnrollmentEntityModel> entities;

  bool get isEmpty => entities.isEmpty;

  EnrollmentEntityModel? get activeEntity {
    for (final EnrollmentEntityModel entity in entities) {
      if (entity.isActiveEntity) return entity;
    }
    return null;
  }

  EnrollmentNodeModel? get activeClass {
    final int? enrollmentId = activeEnrollmentId;
    if (enrollmentId == null) return null;

    for (final EnrollmentEntityModel entity in entities) {
      for (final EnrollmentNodeModel root in entity.tree) {
        for (final EnrollmentNodeModel node in root.flattened()) {
          if (node.enrollmentId == enrollmentId) return node;
        }
      }
    }
    return null;
  }

  /// Every class from the top of the tree down to the active one, in order —
  /// the full educational path shown in the dashboard header card.
  List<EnrollmentNodeModel> get activePath {
    final int? enrollmentId = activeEnrollmentId;
    if (enrollmentId == null) return const <EnrollmentNodeModel>[];

    for (final EnrollmentEntityModel entity in entities) {
      for (final EnrollmentNodeModel root in entity.tree) {
        final List<EnrollmentNodeModel> branch = root.pathTo(enrollmentId);
        if (branch.isNotEmpty) return branch;
      }
    }

    return const <EnrollmentNodeModel>[];
  }

  List<String> get activePathNames => <String>[
    for (final EnrollmentNodeModel node in activePath)
      if (node.name.trim().isNotEmpty) node.name.trim(),
  ];

  factory MyEnrollmentsModel.fromData(Map<String, dynamic> data) =>
      MyEnrollmentsModel(
        activeEnrollmentId: Json.asOptionalInt(data['active_enrollment_id']),
        entities: Json.asList<EnrollmentEntityModel>(
          data['entities'],
          EnrollmentEntityModel.fromJson,
        ),
      );
}
