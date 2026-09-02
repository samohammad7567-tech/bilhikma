import '../enums/account_status_enum.dart';
import '../network/json_reader.dart';
import 'enrollment_model.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.role,
    this.status = AccountStatus.active,
    this.studentNo,
    this.activeEnrollmentId,
    this.canCaptureScreen = false,
    this.enrollments = const <EnrollmentModel>[],
  });

  final int id;
  final String fullName;
  final String? email;
  final String? phone;

  final String? role;
  final AccountStatus status;

  final String? studentNo;
  final int? activeEnrollmentId;

  final bool canCaptureScreen;

  final List<EnrollmentModel> enrollments;

  String get initials => fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .take(2)
      .map((String word) => word.substring(0, 1))
      .join();

  EnrollmentModel? get activeEnrollment {
    final int? activeId = activeEnrollmentId;
    for (final EnrollmentModel enrollment in enrollments) {
      if (activeId != null && enrollment.id == activeId) return enrollment;
    }
    for (final EnrollmentModel enrollment in enrollments) {
      if (enrollment.isCurrent) return enrollment;
    }
    return enrollments.isEmpty ? null : enrollments.first;
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: Json.asInt(json['id']),
    fullName: Json.asString(json['full_name']),
    email: Json.asOptionalString(json['email']),
    phone: Json.asOptionalString(json['phone']),
    role: Json.asOptionalString(json['role']),
    studentNo: Json.asOptionalString(json['student_no']),
    activeEnrollmentId: Json.asOptionalInt(json['active_enrollment_id']),
    canCaptureScreen: Json.asBool(json['can_capture_screen']),
    enrollments: Json.asList<EnrollmentModel>(
      json['enrollments'],
      EnrollmentModel.fromJson,
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    'status': status.name,
    'student_no': studentNo,
    'active_enrollment_id': activeEnrollmentId,
    'can_capture_screen': canCaptureScreen,
    'enrollments': enrollments.map((EnrollmentModel e) => e.toJson()).toList(),
  };
}
