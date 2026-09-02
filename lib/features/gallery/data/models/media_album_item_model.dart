import '../../../../core/network/json_reader.dart';

class MediaAlbumItemModel {
  const MediaAlbumItemModel({required this.id, this.caption, this.orderNo = 0});

  final int id;
  final String? caption;
  final int orderNo;

  factory MediaAlbumItemModel.fromJson(Map<String, dynamic> json) =>
      MediaAlbumItemModel(
        id: Json.asInt(json['id']),
        caption: Json.asOptionalString(json['caption']),
        orderNo: Json.asInt(json['order_no']),
      );
}
