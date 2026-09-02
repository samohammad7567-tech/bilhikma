import '../../../../core/models/enrollment_request_model.dart';
import 'active_pathway_model.dart';

class PathwaySubmissionModel {
  const PathwaySubmissionModel.switched(ActivePathwayModel this.active)
    : request = null;

  const PathwaySubmissionModel.applied(EnrollmentRequestModel this.request)
    : active = null;

  final ActivePathwayModel? active;

  final EnrollmentRequestModel? request;

  bool get isSwitched => active != null;
}
