part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

final class SettingsState {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const SettingsModel(),
    this.isClearingDownloads = false,
    this.errorKey,
    this.messageKey,
  });

  final SettingsStatus status;
  final SettingsModel settings;

  final bool isClearingDownloads;
  final String? errorKey;
  final String? messageKey;

  double get fontScale => settings.fontScale;

  int get fontScalePercent => settings.fontScalePercent;

  SleepTimerOption get sleepTimer => settings.sleepTimer;
  SettingsState copyWith({
    SettingsStatus? status,
    SettingsModel? settings,
    bool? isClearingDownloads,
    String? errorKey,
    String? messageKey,
  }) => SettingsState(
    status: status ?? this.status,
    settings: settings ?? this.settings,
    isClearingDownloads: isClearingDownloads ?? this.isClearingDownloads,
    errorKey: errorKey,
    messageKey: messageKey,
  );
}
