import 'pathway_level_model.dart';

class PathwayStageModel {
  const PathwayStageModel({
    required this.categoryId,
    this.name = '',
    this.levels = const <PathwayLevelModel>[],
  });

  final int categoryId;
  final String name;
  final List<PathwayLevelModel> levels;

  String get id => '$categoryId';
}
