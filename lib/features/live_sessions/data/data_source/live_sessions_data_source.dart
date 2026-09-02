import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/paginated_result.dart';
import '../models/live_attendance_model.dart';
import '../../../../core/models/live_session_model.dart';

class LiveSessionsDataSource {
  const LiveSessionsDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<List<LiveSessionModel>> fetchSessions() async {
    final PaginatedResult<LiveSessionModel> page = await client
        .getPage<LiveSessionModel>(
          ApiEndpoints.liveSessions,
          LiveSessionModel.fromJson,
        );

    return page.items;
  }

  Future<LiveSessionModel> fetchSession(int liveSessionId) =>
      client.getObject<LiveSessionModel>(
        ApiEndpoints.liveSession(liveSessionId),
        LiveSessionModel.fromJson,
      );

  Future<LiveSessionModel?> fetchHighlighted() async {
    final List<LiveSessionModel> sessions = await fetchSessions();
    if (sessions.isEmpty) return null;

    for (final LiveSessionModel session in sessions) {
      if (session.isLive) return session;
    }

    final List<LiveSessionModel> upcoming =
        sessions
            .where((LiveSessionModel session) => session.isUpcoming)
            .toList()
          ..sort((LiveSessionModel a, LiveSessionModel b) {
            final DateTime? left = a.scheduledAt;
            final DateTime? right = b.scheduledAt;
            if (left == null || right == null) return 0;
            return left.compareTo(right);
          });

    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<LiveAttendanceModel> join(int liveSessionId) async {
    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.liveSessionAttendance(liveSessionId),
    );
    return LiveAttendanceModel.fromData(envelope.dataMap);
  }

  Future<LiveAttendanceModel> leave(int liveSessionId) async {
    final ApiEnvelope envelope = await client.delete(
      ApiEndpoints.liveSessionAttendance(liveSessionId),
    );
    return LiveAttendanceModel.fromData(envelope.dataMap);
  }

  Future<LiveAttendanceModel> fetchAttendance(int liveSessionId) =>
      client.getObject<LiveAttendanceModel>(
        ApiEndpoints.liveSessionAttendance(liveSessionId),
        LiveAttendanceModel.fromData,
      );

  Future<LiveAttendanceModel> heartbeat(int liveSessionId) async {
    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.liveSessionHeartbeat(liveSessionId),
    );
    return LiveAttendanceModel.fromData(envelope.dataMap);
  }
}
