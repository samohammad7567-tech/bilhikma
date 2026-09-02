import '../data_source/gallery_data_source.dart';
import '../models/gallery_image_model.dart';
import '../models/media_album_detail_model.dart';
import '../models/media_album_model.dart';

class GalleryRepo {
  const GalleryRepo({this.dataSource = const GalleryDataSource()});

  final GalleryDataSource dataSource;

  Future<List<GalleryImageModel>> fetchImages({bool forceRefresh = false}) =>
      dataSource.fetchImages(forceRefresh: forceRefresh);

  List<GalleryImageModel>? get cachedImages => GalleryDataSource.cachedImages;

  Future<List<MediaAlbumModel>> fetchAlbums({int? categorySubjectId}) =>
      dataSource.fetchAlbums(categorySubjectId: categorySubjectId);

  Future<MediaAlbumDetailModel> fetchAlbum(int albumId) =>
      dataSource.fetchAlbum(albumId);

  Future<String> imageUrl(int albumId, int itemId) =>
      dataSource.imageUrl(albumId, itemId);
}
