import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/my_enrollments_model.dart';
import '../../../enrollments/data/data_source/enrollments_data_source.dart';
import '../../../live_sessions/data/data_source/live_sessions_data_source.dart';
import '../../../../core/models/live_session_model.dart';
import '../models/home_overview_model.dart';

class HomeDataSource {
  const HomeDataSource({
    this.client = const ApiClient(),
    this.liveSessions = const LiveSessionsDataSource(),
    this.enrollments = const EnrollmentsDataSource(),
  });

  final ApiClient client;
  final LiveSessionsDataSource liveSessions;
  final EnrollmentsDataSource enrollments;

  Future<HomeOverviewModel> fetchOverview() =>
      client.getObject<HomeOverviewModel>(
        ApiEndpoints.subjects,
        HomeOverviewModel.fromData,
      );

  /// The stage-to-semester path of the active class, outermost first.
  ///
  /// `/user/subjects` carries only the leaf class name in `context`, so the
  /// ancestry comes from the enrollment tree. Decorative for the header card:
  /// a failure degrades to the leaf name the overview already provides.
  Future<List<String>> fetchEducationalPath() async {
    try {
      final MyEnrollmentsModel enrolled = await enrollments
          .fetchMyEnrollments();

      return enrolled.activePathNames;
    } catch (_) {
      return const <String>[];
    }
  }

  Future<LiveSessionModel?> fetchHighlightedSession() async {
    try {
      return await liveSessions.fetchHighlighted();
    } catch (_) {
      return null;
    }
  }
}
