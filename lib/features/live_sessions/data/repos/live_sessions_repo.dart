import '../data_source/live_sessions_data_source.dart';
import '../models/live_attendance_model.dart';
import '../../../../core/models/live_session_model.dart';

class LiveSessionsRepo {
  const LiveSessionsRepo({this.dataSource = const LiveSessionsDataSource()});

  final LiveSessionsDataSource dataSource;

  Future<List<LiveSessionModel>> fetchSessions() => dataSource.fetchSessions();

  Future<LiveSessionModel> fetchSession(int liveSessionId) =>
      dataSource.fetchSession(liveSessionId);

  Future<LiveSessionModel?> fetchHighlighted() => dataSource.fetchHighlighted();

  Future<LiveAttendanceModel> join(int liveSessionId) =>
      dataSource.join(liveSessionId);

  Future<LiveAttendanceModel> leave(int liveSessionId) =>
      dataSource.leave(liveSessionId);

  Future<LiveAttendanceModel> fetchAttendance(int liveSessionId) =>
      dataSource.fetchAttendance(liveSessionId);

  Future<LiveAttendanceModel> heartbeat(int liveSessionId) =>
      dataSource.heartbeat(liveSessionId);
}
