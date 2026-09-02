class ActivePathwayModel {
  const ActivePathwayModel({
    this.pathwayId = '',
    this.levelId = '',
    this.termId = '',
    this.institutionName = '',
    this.levelName = '',
    this.termName = '',
  });

  final String pathwayId;
  final String levelId;
  final String termId;
  final String institutionName;
  final String levelName;
  final String termName;

  bool get isEmpty => pathwayId.isEmpty || levelId.isEmpty || termId.isEmpty;

  ActivePathwayModel copyWith({
    String? pathwayId,
    String? levelId,
    String? termId,
    String? institutionName,
    String? levelName,
    String? termName,
  }) => ActivePathwayModel(
    pathwayId: pathwayId ?? this.pathwayId,
    levelId: levelId ?? this.levelId,
    termId: termId ?? this.termId,
    institutionName: institutionName ?? this.institutionName,
    levelName: levelName ?? this.levelName,
    termName: termName ?? this.termName,
  );
}
