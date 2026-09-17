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

  /// `file` for an uploaded file behind `/media/{token}`, `youtube` for a
  /// lesson published as a YouTube link.
  final MediaSource source;

  /// Only filled when [source] is `youtube`.
  final String? youtubeUrl;

  bool get isValid => token.isNotEmpty && !isExpired;

  bool get isExpired {
    final DateTime? expiry = expiresAt;
    return expiry != null && expiry.isBefore(DateTime.now());
  }

  /// A YouTube lesson has no token to sign, so it plays straight from its
  /// link; anything else streams through the protected media endpoint.
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
