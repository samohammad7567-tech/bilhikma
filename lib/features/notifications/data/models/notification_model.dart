import '../../../../core/network/json_reader.dart';
import '../../../../core/enums/notification_kind_enum.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.kind,
    required this.title,
    this.message = '',
    this.imageUrl,
    this.deepLink,
    this.isRead = false,
    this.sentAt,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String message;
  final String? imageUrl;

  final String? deepLink;
  final bool isRead;
  final DateTime? sentAt;

  bool get hasDeepLink => (deepLink ?? '').isNotEmpty;

  NotificationModel markRead() => withRead(true);

  NotificationModel withRead(bool read) => isRead == read
      ? this
      : NotificationModel(
          id: id,
          kind: kind,
          title: title,
          message: message,
          imageUrl: imageUrl,
          deepLink: deepLink,
          isRead: read,
          sentAt: sentAt,
        );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: Json.asInt(json['id']),
        kind: NotificationKind.fromJson(json['type']),
        title: Json.asString(json['title']),
        message: Json.asString(json['message']),
        imageUrl: Json.asOptionalString(json['image_url']),
        deepLink: Json.asOptionalString(json['deep_link']),
        isRead: Json.asBool(json['is_read']),
        sentAt: Json.asDateTime(json['sent_at']),
      );
}
