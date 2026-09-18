import '../constants/api_endpoints.dart';
import '../enums/media_source_enum.dart';
import 'json_reader.dart';

class MediaAccessModel {
  const MediaAccessModel({
    required this.token,
    this.expiresAt,
    this.source = MediaSource.file,
    this.youtubeUrl,
  });

  final String token;
  final DateTime? expiresAt;
  final MediaSource source;
  final String? youtubeUrl;

  bool get isValid => token.isNotEmpty && !isExpired;

  bool get isExpired {
    final DateTime? expiry = expiresAt;
    return expiry != null && expiry.isBefore(DateTime.now());
  }

  bool get isYoutube =>
      source.isYoutube && (youtubeUrl ?? '').trim().isNotEmpty;

  String url({required String deviceUuid}) {
    if (isYoutube) return youtubeUrl!.trim();

    return '${ApiEndpoints.baseUrl}${ApiEndpoints.protectedMedia(token)}'
        '?device_uuid=${Uri.encodeQueryComponent(deviceUuid)}';
  }

  factory MediaAccessModel.fromJson(Map<String, dynamic> json) =>
      MediaAccessModel(
        token: Json.asString(json['token']),
        expiresAt: Json.asDateTime(json['expires_at']),
        source: MediaSource.fromJson(json['source']),
        youtubeUrl: Json.asOptionalString(json['youtube_url']),
      );
}
