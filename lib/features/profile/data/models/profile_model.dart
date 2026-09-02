import '../../../../core/network/json_reader.dart';

class ProfileModel {
  const ProfileModel({
    this.id = '',
    this.name = '',
    this.institution = '',
    this.academicPath = '',
    this.path = const <String>[],
    this.phone = '',
    this.email = '',
    this.studentNo = '',
    this.avatarUrl,
    this.canCaptureScreen = false,
  });

  final String id;
  final String name;
  final String institution;

  /// The current class on its own, as the backend labels it. Kept as the
  /// fallback for older responses that carry no [path].
  final String academicPath;

  /// The full educational path, outermost first — stage, then any classes
  /// between, then the current semester. Empty when the backend omits it.
  final List<String> path;

  final String phone;

  final String email;

  final String studentNo;
  final String? avatarUrl;

  final bool canCaptureScreen;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .take(2)
      .map((String word) => word.substring(0, 1))
      .join('.');

  /// What the info card renders for the academic path: the resolved path when
  /// the backend sends one, the class name on its own otherwise.
  List<String> get educationalPath {
    if (path.isNotEmpty) return path;

    final String current = academicPath.trim();

    return current.isEmpty ? const <String>[] : <String>[current];
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? institution,
    String? academicPath,
    List<String>? path,
    String? phone,
    String? email,
    String? studentNo,
    String? avatarUrl,
    bool? canCaptureScreen,
  }) => ProfileModel(
    id: id ?? this.id,
    name: name ?? this.name,
    institution: institution ?? this.institution,
    academicPath: academicPath ?? this.academicPath,
    path: path ?? this.path,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    studentNo: studentNo ?? this.studentNo,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    canCaptureScreen: canCaptureScreen ?? this.canCaptureScreen,
  );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: '${json['id'] ?? ''}',
    name: '${json['name'] ?? json['full_name'] ?? ''}',
    institution: '${json['institution'] ?? ''}',
    academicPath: '${json['academic_path'] ?? json['academic_level'] ?? ''}',
    path: _pathNames(json['path']),
    phone: '${json['phone'] ?? json['phone_number'] ?? ''}',
    email: '${json['email'] ?? ''}',
    studentNo: '${json['student_no'] ?? ''}',
    avatarUrl: _optional(json['avatar_url'] ?? json['avatar']),
    canCaptureScreen: Json.asBool(json['can_capture_screen']),
  );
  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'institution': institution,
    'academic_path': academicPath,
    'path': path,
    'phone': phone,
    'avatar_url': avatarUrl,
  };

  /// `path` arrives as `[{id, name}, …]`, ordered from the stage down to the
  /// current class. Only the names reach the UI; unnamed nodes are dropped so
  /// a partial tree cannot render an empty chevron segment.
  static List<String> _pathNames(Object? value) => <String>[
    for (final Map<String, dynamic> node in Json.asMapList(value))
      if (Json.asString(node['name']).trim().isNotEmpty)
        Json.asString(node['name']).trim(),
  ];

  static String? _optional(Object? value) {
    final String text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }
}
