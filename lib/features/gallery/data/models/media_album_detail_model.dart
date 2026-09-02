import '../../../../core/network/json_reader.dart';
import 'media_album_item_model.dart';

class MediaAlbumDetailModel {
  const MediaAlbumDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.albumDate,
    this.items = const <MediaAlbumItemModel>[],
  });

  final int id;
  final String title;
  final String? description;
  final DateTime? albumDate;
  final List<MediaAlbumItemModel> items;

  bool get isEmpty => items.isEmpty;

  factory MediaAlbumDetailModel.fromData(Map<String, dynamic> data) =>
      MediaAlbumDetailModel(
        id: Json.asInt(data['id']),
        title: Json.asString(data['title']),
        description: Json.asOptionalString(data['description']),
        albumDate: Json.asDate(data['album_date']),
        items: Json.asList<MediaAlbumItemModel>(
          data['items'],
          MediaAlbumItemModel.fromJson,
        ),
      );
}
