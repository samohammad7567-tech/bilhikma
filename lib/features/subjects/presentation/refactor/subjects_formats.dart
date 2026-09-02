import 'package:easy_localization/easy_localization.dart';

class SubjectsFormats {
  SubjectsFormats._();

  static String lessons(int count) =>
      'lesson_count'.tr(namedArgs: <String, String>{'count': '$count'});
}
