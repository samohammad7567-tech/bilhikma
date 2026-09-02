import 'package:easy_localization/easy_localization.dart';

class SubjectContentFormats {
  SubjectContentFormats._();

  static String isoDate(DateTime date) =>
      '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';

  static String edition(DateTime date) =>
      'book_edition'.tr(namedArgs: <String, String>{'date': isoDate(date)});

  static String fileSize(double megabytes) => 'book_file_size'.tr(
    namedArgs: <String, String>{'size': _trimZero(megabytes)},
  );

  static String pages(int count) =>
      'book_page_count'.tr(namedArgs: <String, String>{'count': '$count'});

  static String _trimZero(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
