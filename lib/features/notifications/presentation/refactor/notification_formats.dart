import 'package:easy_localization/easy_localization.dart';

class NotificationFormats {
  NotificationFormats._();

  static String relativeTime(DateTime createdAt, {DateTime? now}) {
    final Duration age = (now ?? DateTime.now()).difference(createdAt);

    if (age.inMinutes < 1) return 'since_now'.tr();

    if (age.inHours < 1) return _since('since_minutes', age.inMinutes);

    if (age.inDays < 1) return _since('since_hours', age.inHours);

    return _since('since_days', age.inDays);
  }

  static String stamp(DateTime? sentAt, {DateTime? now}) {
    if (sentAt == null) return 'notification_scheduled'.tr();

    final DateTime today = now ?? DateTime.now();
    if (today.difference(sentAt).inMinutes < 60) {
      return relativeTime(sentAt, now: today);
    }

    return '${dayLabel(sentAt, now: today)} ${clock(sentAt)}';
  }

  static String dayLabel(DateTime? sentAt, {DateTime? now}) {
    if (sentAt == null) return 'notification_scheduled'.tr();

    final int days = _dayNumber(now ?? DateTime.now()) - _dayNumber(sentAt);

    if (days <= 0) return 'today'.tr();
    if (days == 1) return 'yesterday'.tr();

    return '${_two(sentAt.day)}/${_two(sentAt.month)}/${sentAt.year}';
  }

  static String clock(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String period = time.hour < 12 ? 'time_am'.tr() : 'time_pm'.tr();

    return '${_two(hour)}:${_two(time.minute)} $period';
  }

  static int dayNumber(DateTime time) => _dayNumber(time);

  static int _dayNumber(DateTime time) =>
      DateTime(time.year, time.month, time.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _since(String key, int count) =>
      key.tr(namedArgs: <String, String>{'count': '$count'});
}
