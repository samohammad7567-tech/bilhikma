import 'package:easy_localization/easy_localization.dart';
import '../../../../core/models/live_session_model.dart';

class HomeFormats {
  HomeFormats._();

  static String percent(double progress) => '${(progress * 100).round()}%';

  static String overallProgress(double progress) => 'overall_progress'.tr(
    namedArgs: <String, String>{'percent': percent(progress)},
  );

  static String lessons(int count) =>
      'lesson_count'.tr(namedArgs: <String, String>{'count': '$count'});

  static String minutes(int count) =>
      'minute_count'.tr(namedArgs: <String, String>{'count': '$count'});

  static String subjectDuration(String subject, int minutes) =>
      'subject_duration'.tr(
        namedArgs: <String, String>{
          'subject': subject,
          'duration': HomeFormats.minutes(minutes),
        },
      );

  static String liveHeadline(LiveSessionModel session) {
    if (session.isLive) return 'live_now'.tr();

    final DateTime? scheduledAt = session.scheduledAt;

    if (scheduledAt == null) return 'live_now'.tr();

    final String time = _clockTime(scheduledAt);

    if (_isToday(scheduledAt)) {
      return 'live_headline_tonight'.tr(
        namedArgs: <String, String>{'time': time},
      );
    }

    return 'live_headline_on_date'.tr(
      namedArgs: <String, String>{
        'date': '${scheduledAt.day}/${scheduledAt.month}',
        'time': time,
      },
    );
  }

  static String liveBadge(LiveSessionModel session) =>
      session.isLive ? 'live_now'.tr() : 'upcoming'.tr();

  static String _clockTime(DateTime moment) {
    final int hour12 = moment.hour % 12 == 0 ? 12 : moment.hour % 12;
    final String meridiem = moment.hour < 12 ? 'am'.tr() : 'pm'.tr();

    return '${_twoDigits(hour12)}:${_twoDigits(moment.minute)} $meridiem';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static bool _isToday(DateTime moment) {
    final DateTime now = DateTime.now();
    return moment.year == now.year &&
        moment.month == now.month &&
        moment.day == now.day;
  }
}
