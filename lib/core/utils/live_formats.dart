import 'package:easy_localization/easy_localization.dart';

class LiveFormats {
  LiveFormats._();

  static String time(DateTime moment) {
    final int hour12 = moment.hour % 12 == 0 ? 12 : moment.hour % 12;
    final String meridiem = moment.hour < 12 ? 'am'.tr() : 'pm'.tr();

    return '${_twoDigits(hour12)}:${_twoDigits(moment.minute)} $meridiem';
  }

  static String date(DateTime date) =>
      '${_twoDigits(date.day)}-${_twoDigits(date.month)}-${date.year}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
