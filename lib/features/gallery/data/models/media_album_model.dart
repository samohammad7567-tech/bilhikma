import '../../../../core/network/json_reader.dart';

class MediaAlbumModel {
  const MediaAlbumModel({
    required this.id,
    required this.title,
    this.description,
    this.albumDate,
    this.itemsCount = 0,
  });

  final int id;
  final String title;
  final String? description;

  final DateTime? albumDate;
  final int itemsCount;

  bool get isEmpty => itemsCount == 0;

  factory MediaAlbumModel.fromJson(Map<String, dynamic> json) =>
      MediaAlbumModel(
        id: Json.asInt(json['id']),
        title: Json.asString(json['title']),
        description: Json.asOptionalString(json['description']),
        albumDate: Json.asDate(json['album_date']),
        itemsCount: Json.asInt(json['items_count']),
      );
}
