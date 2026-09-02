import '../data_source/security_data_source.dart';
import '../models/security_event_model.dart';

class SecurityRepo {
  const SecurityRepo({this.dataSource = const SecurityDataSource()});

  final SecurityDataSource dataSource;

  Future<SecurityEventResponseModel> reportEvent(
    SecurityEventRequestModel request,
  ) => dataSource.reportEvent(request);

  Future<void> endSession() => dataSource.endSession();
}
