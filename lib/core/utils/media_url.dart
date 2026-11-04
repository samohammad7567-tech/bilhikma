import '../constants/api_endpoints.dart';

class MediaUrl {
  MediaUrl._();

  static String? resolve(String? value) {
    final String path = value?.trim() ?? '';
    if (path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('assets/')) return path;

    final String relative = path.startsWith('/') ? path.substring(1) : path;

    if (relative.startsWith('storage/')) {
      return '${ApiEndpoints.origin}/$relative';
    }

    return '${ApiEndpoints.storageBaseUrl}/$relative';
  }
}
