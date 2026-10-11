import '../../data/models/notification_model.dart';
import 'notification_formats.dart';

/// One day's worth of notifications, in the order the API returned them.
class NotificationDayGroup {
  const NotificationDayGroup({required this.day, required this.items});

  /// Null for notifications that have not been sent yet.
  final DateTime? day;

  final List<NotificationModel> items;

  String get label => NotificationFormats.dayLabel(day);

  /// Splits a list that is already newest first into consecutive days.
  ///
  /// Consecutive, not grouped by key: the list is sorted, so a day cannot
  /// reappear later, and walking it keeps the server's order intact.
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
