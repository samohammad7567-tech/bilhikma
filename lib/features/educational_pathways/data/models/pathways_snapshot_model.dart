import 'active_pathway_model.dart';
import 'educational_pathway_model.dart';

class PathwaysSnapshotModel {
  const PathwaysSnapshotModel({
    this.pathways = const <EducationalPathwayModel>[],
    this.active = const ActivePathwayModel(),
  });

  final List<EducationalPathwayModel> pathways;

  final ActivePathwayModel active;
}
