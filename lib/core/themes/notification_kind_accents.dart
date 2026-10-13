import 'package:flutter/material.dart';

import '../enums/notification_kind_enum.dart';

class NotificationKindAccents {
  NotificationKindAccents._();
  static const double chipTint = 0.16;

  static Color of(BuildContext context, NotificationKind kind) =>
      Theme.of(context).brightness == Brightness.dark
      ? _dark[kind]!
      : _light[kind]!;

  static const Map<NotificationKind, Color> _light = <NotificationKind, Color>{
    NotificationKind.newContent: Color(0xff1F6B35),
    NotificationKind.liveSession: Color(0xff8A6A22),
    NotificationKind.liveReminder: Color(0xffC77A1E),
    NotificationKind.enrollmentApproved: Color(0xff2E9E52),
    NotificationKind.accountStatus: Color(0xff6E6C66),
    NotificationKind.inactivityWarning: Color(0xffBC4A42),
    NotificationKind.adminAnnouncement: Color(0xff7A6A4C),
    NotificationKind.custom: Color(0xff1E9E74),
  };
  static const Map<NotificationKind, Color> _dark = <NotificationKind, Color>{
    NotificationKind.newContent: Color(0xff7FC68F),
    NotificationKind.liveSession: Color(0xffD9B86B),
    NotificationKind.liveReminder: Color(0xffE8A95C),
    NotificationKind.enrollmentApproved: Color(0xff74D18F),
    NotificationKind.accountStatus: Color(0xffB8B5AE),
    NotificationKind.inactivityWarning: Color(0xffE98C84),
    NotificationKind.adminAnnouncement: Color(0xffCDB98F),
    NotificationKind.custom: Color(0xff6FD5AF),
  };
}
