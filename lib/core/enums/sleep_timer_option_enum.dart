enum SleepTimerOption {
  off(0),
  fifteenMinutes(15),
  thirtyMinutes(30),
  fortyFiveMinutes(45),
  oneHour(60),
  ninetyMinutes(90);

  const SleepTimerOption(this.minutes);

  final int minutes;

  bool get isOff => minutes == 0;
  static List<SleepTimerOption> get selectable => SleepTimerOption.values
      .where((SleepTimerOption option) => !option.isOff)
      .toList(growable: false);

  static SleepTimerOption fromMinutes(int minutes) {
    return SleepTimerOption.values.lastWhere(
      (SleepTimerOption option) => option.minutes <= minutes,
      orElse: () => SleepTimerOption.off,
    );
  }
}
