import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/services/device_session_service.dart';
import '../models/security_event_model.dart';

class SecurityDataSource {
  const SecurityDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<SecurityEventResponseModel> reportEvent(
    SecurityEventRequestModel request,
  ) async {
    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.securityEvents,
      data: request.toJson(),
    );

    return SecurityEventResponseModel.fromData(envelope.dataMap);
  }

  Future<void> endSession() => DeviceSessionService.clear();
}
