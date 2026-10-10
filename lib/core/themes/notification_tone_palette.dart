import 'package:flutter/material.dart';

import '../enums/notification_tone_enum.dart';

/// Colours one notification category, in one theme.
///
/// Every pair that meets on screen — [title] and [body] over [background],
/// [onAccent] over [accent] — clears WCAG AA for body text in both themes, so
/// a card stays readable whichever palette the device is on.
@immutable
class NotificationTonePalette {
  const NotificationTonePalette({
    required this.background,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.iconInk,
    required this.title,
    required this.body,
  });

  /// Card background while the notification is unread.
  final Color background;

  final Color border;

  /// Strongest colour of the family: accent bar, category chip, icon tint.
  final Color accent;

  final Color onAccent;

  /// Tint for monochrome artwork. The icon tile is light in both themes, so
  /// this stays dark in both — unlike [accent], which lightens for dark mode.
  final Color iconInk;

  final Color title;

  /// Message and metadata text.
  final Color body;

  static NotificationTonePalette of(
    BuildContext context,
    NotificationTone tone,
  ) => Theme.of(context).brightness == Brightness.dark
      ? _dark[tone]!
      : _light[tone]!;

  /// Background once the notification has been read: the same hue, settled
  /// part of the way back towards the page so unread cards keep the most
  /// weight while the family stays readable at a glance.
  Color readBackground(ColorScheme colors) =>
      Color.lerp(background, colors.surface, 0.45) ?? background;

  static const Map<NotificationTone, NotificationTonePalette> _light =
      <NotificationTone, NotificationTonePalette>{
        NotificationTone.administrative: NotificationTonePalette(
          background: Color(0xffF0D9A4),
          border: Color(0xffC09A3F),
          accent: Color(0xff7A5A1E),
          onAccent: Colors.white,
          iconInk: Color(0xff7A5A1E),
          title: Color(0xff3E2F12),
          body: Color(0xff6A5324),
        ),
        NotificationTone.alert: NotificationTonePalette(
          background: Color(0xffFBD5C4),
          border: Color(0xffDB7D4F),
          accent: Color(0xffB3401A),
          onAccent: Colors.white,
          iconInk: Color(0xffB3401A),
          title: Color(0xff4A1A08),
          body: Color(0xff7A3418),
        ),
        NotificationTone.lesson: NotificationTonePalette(
          background: Color(0xffCDEBD2),
          border: Color(0xff5E9E6B),
          accent: Color(0xff1F6B35),
          onAccent: Colors.white,
          iconInk: Color(0xff1F6B35),
          title: Color(0xff10351C),
          body: Color(0xff2E5A3A),
        ),
      };

  static const Map<NotificationTone, NotificationTonePalette> _dark =
      <NotificationTone, NotificationTonePalette>{
        NotificationTone.administrative: NotificationTonePalette(
          background: Color(0xff2F2718),
          border: Color(0xff7A6228),
          accent: Color(0xffE3C27A),
          onAccent: Color(0xff2A2008),
          iconInk: Color(0xff7A5A1E),
          title: Color(0xffF4E9D4),
          body: Color(0xffD3C2A0),
        ),
        NotificationTone.alert: NotificationTonePalette(
          background: Color(0xff3A1A11),
          border: Color(0xff8A4428),
          accent: Color(0xffFF9B6A),
          onAccent: Color(0xff3A1604),
          iconInk: Color(0xffB3401A),
          title: Color(0xffFBE3D8),
          body: Color(0xffE0B9A6),
        ),
        NotificationTone.lesson: NotificationTonePalette(
          background: Color(0xff15301C),
          border: Color(0xff3C6B46),
          accent: Color(0xff76C98C),
          onAccent: Color(0xff06240F),
          iconInk: Color(0xff1F6B35),
          title: Color(0xffE3F3E6),
          body: Color(0xffB7D4BE),
        ),
      };
}
