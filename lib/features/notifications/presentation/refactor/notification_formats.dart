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

  static String _since(String key, int count) =>
      key.tr(namedArgs: <String, String>{'count': '$count'});
}
