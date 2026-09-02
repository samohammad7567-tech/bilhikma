import '../network/json_reader.dart';

enum EnrollmentStatus {
  pending('pending'),
  approved('approved'),
  archived('archived'),
  rejected('rejected');

  const EnrollmentStatus(this.key);

  final String key;

  bool get isSelectable =>
      this == EnrollmentStatus.approved || this == EnrollmentStatus.archived;

  bool get isArchived => this == EnrollmentStatus.archived;

  static EnrollmentStatus? fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    if (key.isEmpty) return null;

    for (final EnrollmentStatus status in EnrollmentStatus.values) {
      if (status.key == key) return status;
    }
    return null;
  }
}
