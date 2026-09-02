enum ResetChannel {
  email('email'),
  sms('sms'),
  whatsapp('whatsapp');

  const ResetChannel(this.key);

  final String key;

  bool get isEmail => this == ResetChannel.email;

  bool get wantsEmailAddress => isEmail;

  static ResetChannel fromJson(Object? value) => switch (value) {
    'email' => ResetChannel.email,
    'whatsapp' => ResetChannel.whatsapp,
    _ => ResetChannel.sms,
  };
}
