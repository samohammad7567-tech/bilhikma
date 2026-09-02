import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/media_access_model.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../../core/services/device_service.dart';
import '../models/gallery_image_model.dart';
import '../models/media_album_detail_model.dart';
import '../models/media_album_item_model.dart';
import '../models/media_album_model.dart';

class GalleryDataSource {
  const GalleryDataSource({this.client = const ApiClient()});

  final ApiClient client;

  static List<GalleryImageModel>? _cachedImages;
  static DateTime? _cachedUntil;

  static const Duration _fallbackTtl = Duration(minutes: 10);

  static List<GalleryImageModel>? get cachedImages =>
      _isCacheWarm ? _cachedImages : null;

  static bool get _isCacheWarm {
    final DateTime? until = _cachedUntil;
    return _cachedImages != null &&
        until != null &&
        until.isAfter(DateTime.now());
  }

  static void clearCache() {
    _cachedImages = null;
    _cachedUntil = null;
  }

  Future<List<MediaAlbumModel>> fetchAlbums({
    int perPage = 15,
    int? categorySubjectId,
  }) async {
    final PaginatedResult<MediaAlbumModel> page = await client
        .getPage<MediaAlbumModel>(
          ApiEndpoints.mediaAlbums,
          MediaAlbumModel.fromJson,
          queryParameters: <String, dynamic>{
            'per_page': perPage,
            'category_subject_id': ?categorySubjectId,
          },
        );

    return page.items;
  }

  Future<MediaAlbumDetailModel> fetchAlbum(int albumId) =>
      client.getObject<MediaAlbumDetailModel>(
        ApiEndpoints.mediaAlbum(albumId),
        MediaAlbumDetailModel.fromData,
      );

  Future<String> imageUrl(int albumId, int itemId) async {
    final MediaAccessModel access = await _imageAccess(albumId, itemId);
    return access.url(deviceUuid: DeviceService.deviceUuid);
  }

  Future<MediaAccessModel> _imageAccess(int albumId, int itemId) async {
    await DeviceService.ensureInitialized();

    final ApiEnvelope envelope = await client.post(
      ApiEndpoints.mediaAlbumItemAccessToken(albumId, itemId),
      data: <String, dynamic>{'device_uuid': DeviceService.deviceUuid},
    );

    return MediaAccessModel.fromJson(envelope.dataMap);
  }

  Future<List<GalleryImageModel>> fetchImages({
    int maxAlbums = 5,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheWarm) return _cachedImages!;

    final List<MediaAlbumModel> albums = await fetchAlbums();
    if (albums.isEmpty) {
      _store(const <GalleryImageModel>[], null);
      return const <GalleryImageModel>[];
    }

    final List<GalleryImageModel> images = <GalleryImageModel>[];
    DateTime? soonestExpiry;

    for (final MediaAlbumModel album in albums.take(maxAlbums)) {
      final MediaAlbumDetailModel detail = await fetchAlbum(album.id);

      final List<(GalleryImageModel, DateTime?)> resolved = await Future.wait(
        detail.items.map((MediaAlbumItemModel item) async {
          final MediaAccessModel access = await _imageAccess(album.id, item.id);

          return (
            GalleryImageModel(
              id: '${album.id}-${item.id}',
              imageUrl: access.url(deviceUuid: DeviceService.deviceUuid),
              caption: item.caption ?? album.title,
            ),
            access.expiresAt,
          );
        }),
      );

      for (final (GalleryImageModel image, DateTime? expiry) in resolved) {
        images.add(image);
        soonestExpiry = _earlier(soonestExpiry, expiry);
      }
    }

    _store(images, soonestExpiry);
    return images;
  }

  static void _store(List<GalleryImageModel> images, DateTime? soonestExpiry) {
    _cachedImages = images;
    _cachedUntil = soonestExpiry ?? DateTime.now().add(_fallbackTtl);
  }

  static DateTime? _earlier(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }
}
