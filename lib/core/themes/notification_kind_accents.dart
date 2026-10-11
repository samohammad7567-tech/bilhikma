import 'package:flutter/material.dart';

import '../enums/notification_kind_enum.dart';

/// One colour per notification category, used for the chip that names it.
///
/// The tone palette colours the card itself and has three families, which is
/// deliberately coarse. The chip is where a category is told apart from its
/// siblings, so it gets its own hue: two live notices and an account notice
/// otherwise look identical at a glance.
class NotificationKindAccents {
  NotificationKindAccents._();

  /// Share of the accent mixed into the chip background.
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

  /// Lifted for dark cards — the light values sit too close to the surface
  /// to read as text.
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
