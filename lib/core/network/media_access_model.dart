import '../constants/api_endpoints.dart';
import 'json_reader.dart';

class MediaAccessModel {
  const MediaAccessModel({required this.token, this.expiresAt});

  final String token;
  final DateTime? expiresAt;

  bool get isValid => token.isNotEmpty && !isExpired;

  bool get isExpired {
    final DateTime? expiry = expiresAt;
    return expiry != null && expiry.isBefore(DateTime.now());
  }

  String url({required String deviceUuid}) =>
      '${ApiEndpoints.baseUrl}${ApiEndpoints.protectedMedia(token)}'
      '?device_uuid=${Uri.encodeQueryComponent(deviceUuid)}';

  factory MediaAccessModel.fromJson(Map<String, dynamic> json) =>
      MediaAccessModel(
        token: Json.asString(json['token']),
        expiresAt: Json.asDateTime(json['expires_at']),
      );
}
