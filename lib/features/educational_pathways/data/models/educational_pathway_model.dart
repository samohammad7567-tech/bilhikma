import 'pathway_level_model.dart';
import 'pathway_stage_model.dart';

class EducationalPathwayModel {
  const EducationalPathwayModel({
    required this.entityId,
    this.institutionName = '',
    this.logoUrl,
    this.stages = const <PathwayStageModel>[],
  });

  final int entityId;
  final String institutionName;
  final String? logoUrl;
  final List<PathwayStageModel> stages;

  String get id => '$entityId';

  bool get hasClasses => stages.isNotEmpty;

  List<PathwayLevelModel> get levels => <PathwayLevelModel>[
    for (final PathwayStageModel stage in stages) ...stage.levels,
  ];

  PathwayLevelModel? levelById(String? levelId) {
    if (levelId == null) return null;

    for (final PathwayLevelModel level in levels) {
      if (level.id == levelId) return level;
    }

    return null;
  }

  EducationalPathwayModel copyWith({List<PathwayStageModel>? stages}) =>
      EducationalPathwayModel(
        entityId: entityId,
        institutionName: institutionName,
        logoUrl: logoUrl,
        stages: stages ?? this.stages,
      );
}
