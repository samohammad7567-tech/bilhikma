import '../network/json_reader.dart';

class PublicCategoryModel {
  const PublicCategoryModel({
    required this.id,
    required this.name,
    this.orderNo = 0,
    this.isSelectable = false,
    this.children = const <PublicCategoryModel>[],
  });

  final int id;
  final String name;
  final int orderNo;
  final bool isSelectable;
  final List<PublicCategoryModel> children;

  bool get hasChildren => children.isNotEmpty;

  factory PublicCategoryModel.fromJson(Map<String, dynamic> json) =>
      PublicCategoryModel(
        id: Json.asInt(json['id']),
        name: Json.asString(json['name']),
        orderNo: Json.asInt(json['order_no']),
        isSelectable: Json.asBool(json['is_selectable']),
        children: Json.asList<PublicCategoryModel>(
          json['children'],
          PublicCategoryModel.fromJson,
        ),
      );

  Iterable<PublicCategoryModel> flattened() sync* {
    yield this;
    for (final PublicCategoryModel child in children) {
      yield* child.flattened();
    }
  }
}
