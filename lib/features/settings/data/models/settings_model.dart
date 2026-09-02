import '../../../../core/enums/sleep_timer_option_enum.dart';

class SettingsModel {
  const SettingsModel({
    this.fontScale = defaultFontScale,
    this.sleepTimerMinutes = 0,
  });
  static const double defaultFontScale = 1;
  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.5;
  static const double fontScaleStep = 0.1;

  final double fontScale;
  final int sleepTimerMinutes;

  SleepTimerOption get sleepTimer =>
      SleepTimerOption.fromMinutes(sleepTimerMinutes);
  int get fontScalePercent => (fontScale * 100).round();

  bool get canIncreaseFont => fontScale < maxFontScale;

  bool get canDecreaseFont => fontScale > minFontScale;
  static double normaliseScale(double scale) {
    final double stepped =
        (scale / fontScaleStep).roundToDouble() * fontScaleStep;

    return stepped.clamp(minFontScale, maxFontScale);
  }

  SettingsModel copyWith({double? fontScale, int? sleepTimerMinutes}) =>
      SettingsModel(
        fontScale: fontScale ?? this.fontScale,
        sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
      );

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    fontScale: normaliseScale(
      (json['font_scale'] as num?)?.toDouble() ?? defaultFontScale,
    ),
    sleepTimerMinutes: (json['sleep_timer_minutes'] as num?)?.round() ?? 0,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'font_scale': fontScale,
    'sleep_timer_minutes': sleepTimerMinutes,
  };
}
