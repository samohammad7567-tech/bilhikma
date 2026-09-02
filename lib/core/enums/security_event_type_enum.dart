enum SecurityEventType {
  screenshot('screenshot'),
  screenRecord('screen_record'),
  externalDisplay('external_display');

  const SecurityEventType(this.key);

  final String key;
}
