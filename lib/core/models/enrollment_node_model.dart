import '../enums/enrollment_status_enum.dart';
import '../network/json_reader.dart';

class EnrollmentNodeModel {
  const EnrollmentNodeModel({
    required this.categoryId,
    required this.name,
    this.orderNo = 0,
    this.enrollmentId,
    this.status,
    this.isActive = false,
    this.children = const <EnrollmentNodeModel>[],
  });

  final int categoryId;
  final String name;
  final int orderNo;

  final int? enrollmentId;
  final EnrollmentStatus? status;

  final bool isActive;
  final List<EnrollmentNodeModel> children;

  bool get isGroup => enrollmentId == null;

  bool get isSelectable =>
      enrollmentId != null && (status?.isSelectable ?? false);

  bool get hasChildren => children.isNotEmpty;

  factory EnrollmentNodeModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentNodeModel(
        categoryId: Json.asInt(json['category_id']),
        name: Json.asString(json['name']),
        orderNo: Json.asInt(json['order_no']),
        enrollmentId: Json.asOptionalInt(json['enrollment_id']),
        status: EnrollmentStatus.fromJson(json['status']),
        isActive: Json.asBool(json['is_active']),
        children: Json.asList<EnrollmentNodeModel>(
          json['children'],
          EnrollmentNodeModel.fromJson,
        ),
      );

  Iterable<EnrollmentNodeModel> flattened() sync* {
    yield this;
    for (final EnrollmentNodeModel child in children) {
      yield* child.flattened();
    }
  }

  /// The branch from this node down to the node carrying [enrollmentId],
  /// this node included. Empty when the branch does not hold that enrollment.
  ///
  /// `/user/subjects` only returns the leaf class, so the header card rebuilds
  /// the ancestry from the enrollment tree instead.
  List<EnrollmentNodeModel> pathTo(int enrollmentId) {
    if (this.enrollmentId == enrollmentId) return <EnrollmentNodeModel>[this];

    for (final EnrollmentNodeModel child in children) {
      final List<EnrollmentNodeModel> branch = child.pathTo(enrollmentId);
      if (branch.isNotEmpty) return <EnrollmentNodeModel>[this, ...branch];
    }

    return const <EnrollmentNodeModel>[];
  }
}
