import 'package:easy_localization/easy_localization.dart';
import '../../../../core/enums/sleep_timer_option_enum.dart';

class SettingsFormats {
  SettingsFormats._();
  static String sleepTimer(SleepTimerOption option) => option.isOff
      ? 'sleep_timer_off'.tr()
      : 'minute_count'.tr(
          namedArgs: <String, String>{'count': '${option.minutes}'},
        );
  static String fontScale(int percent) => '$percent%';
}
