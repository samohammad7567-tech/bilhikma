import '../utils/error_mapper.dart';

class SessionPolicy {
  SessionPolicy._();

  static bool shouldEndStatus(int? statusCode, {required bool endOnForbidden}) {
    if (statusCode == 403 && !endOnForbidden) return false;
    return ErrorMapper.endsSession(statusCode);
  }

  static bool shouldEnd(AppException error, {required bool endOnForbidden}) {
    if (error.statusCode == 403 && !endOnForbidden) return false;
    return error.endsSession;
  }
}
