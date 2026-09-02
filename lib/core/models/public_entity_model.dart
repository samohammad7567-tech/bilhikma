import '../network/json_reader.dart';

class PublicEntityModel {
  const PublicEntityModel({
    required this.id,
    required this.name,
    this.slug,
    this.type,
    this.description,
    this.logoUrl,
    this.orderNo = 0,
    this.isActive = true,
    this.isOpenForRegistration = true,
  });

  final int id;
  final String name;
  final String? slug;

  final String? type;
  final String? description;
  final String? logoUrl;
  final int orderNo;
  final bool isActive;
  final bool isOpenForRegistration;

  factory PublicEntityModel.fromJson(Map<String, dynamic> json) =>
      PublicEntityModel(
        id: Json.asInt(json['id']),
        name: Json.asString(json['name']),
        slug: Json.asOptionalString(json['slug']),
        type: Json.asOptionalString(json['type']),
        description: Json.asOptionalString(json['description']),
        logoUrl: Json.asOptionalString(json['logo_url']),
        orderNo: Json.asInt(json['order_no']),
        isActive: Json.asBool(json['is_active']),
        isOpenForRegistration: Json.asBool(json['is_open_for_registration']),
      );
}
