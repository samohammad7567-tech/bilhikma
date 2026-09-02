class PathwaySelectionModel {
  const PathwaySelectionModel({this.pathwayId, this.levelId, this.termId});

  final String? pathwayId;
  final String? levelId;
  final String? termId;

  bool get isComplete =>
      (pathwayId?.isNotEmpty ?? false) &&
      (levelId?.isNotEmpty ?? false) &&
      (termId?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'pathway_id': pathwayId,
    'level_id': levelId,
    'term_id': termId,
  };
}
