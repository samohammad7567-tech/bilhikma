import 'package:easy_localization/easy_localization.dart';

class LessonFormats {
  LessonFormats._();
  static String duration(Duration duration) => 'lesson_duration'.tr(
    namedArgs: <String, String>{'duration': _clock(duration)},
  );
  static String date(DateTime date) =>
      '${_twoDigits(date.day)}-${_twoDigits(date.month)}-${date.year}';
  static String attachments(int count) =>
      'pdf_files_count'.tr(namedArgs: <String, String>{'count': '$count'});

  static String _clock(Duration duration) {
    final String minutes = _twoDigits(duration.inMinutes.remainder(60));
    final String seconds = _twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours == 0) return '$minutes:$seconds';
    return '${_twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
