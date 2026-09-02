class PathwayTermModel {
  const PathwayTermModel({
    required this.categoryId,
    this.name = '',
    this.enrollmentId,
    this.isSwitchable = false,
    this.isJoinable = false,
    this.isActive = false,
  });

  final int categoryId;
  final String name;

  final int? enrollmentId;

  final bool isSwitchable;

  final bool isJoinable;

  final bool isActive;

  String get id => '$categoryId';

  bool get isEnrolled => enrollmentId != null;

  bool get isOfferable => isEnrolled || isJoinable;
}
