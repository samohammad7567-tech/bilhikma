import '../data_source/educational_pathways_data_source.dart';
import '../models/educational_pathway_model.dart';
import '../models/pathway_selection_model.dart';
import '../models/pathway_submission_model.dart';
import '../models/pathways_snapshot_model.dart';

class EducationalPathwaysRepo {
  const EducationalPathwaysRepo({
    this.dataSource = const EducationalPathwaysDataSource(),
  });

  final EducationalPathwaysDataSource dataSource;

  Future<PathwaysSnapshotModel> fetchPathways() => dataSource.fetchPathways();

  Future<List<EducationalPathwayModel>> fetchInstitutes(
    List<EducationalPathwayModel> enrolledIn,
  ) => dataSource.fetchInstitutes(enrolledIn);

  Future<EducationalPathwayModel> fetchClasses(
    EducationalPathwayModel institute,
  ) => dataSource.fetchClasses(institute);

  Future<PathwaySubmissionModel> submitSelection(
    EducationalPathwayModel institute,
    PathwaySelectionModel selection,
  ) => dataSource.submitSelection(institute, selection);
}
