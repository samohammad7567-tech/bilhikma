import '../../data/models/notification_model.dart';
import 'notification_formats.dart';

class NotificationDayGroup {
  const NotificationDayGroup({required this.day, required this.items});
  final DateTime? day;

  final List<NotificationModel> items;

  String get label => NotificationFormats.dayLabel(day);
  static List<NotificationDayGroup> build(List<NotificationModel> items) {
    final List<NotificationDayGroup> groups = <NotificationDayGroup>[];

    int? currentDay;
    List<NotificationModel> bucket = <NotificationModel>[];
    DateTime? bucketDay;

    for (final NotificationModel item in items) {
      final DateTime? sentAt = item.sentAt;
      final int? day = sentAt == null
          ? null
          : NotificationFormats.dayNumber(sentAt);

      if (bucket.isEmpty || day != currentDay) {
        if (bucket.isNotEmpty) {
          groups.add(NotificationDayGroup(day: bucketDay, items: bucket));
        }

        currentDay = day;
        bucketDay = sentAt;
        bucket = <NotificationModel>[];
      }

      bucket.add(item);
    }

    if (bucket.isNotEmpty) {
      groups.add(NotificationDayGroup(day: bucketDay, items: bucket));
    }

    return groups;
  }
}
