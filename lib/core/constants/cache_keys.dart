class CacheKeys {
  CacheKeys._();
  static const String isDark = 'isDark';
  static const String fontScale = 'font_scale';
  static const String sleepTimerMinutes = 'sleep_timer_minutes';
  static const String playbackSpeed = 'playback_speed';
  static const String rememberMeKey = 'remember_me';
  static const String rememberedIdentifierKey = 'remembered_identifier';
  static const String rememberedMethodKey = 'remembered_login_method';

  static const String cachedUserKey = 'cached_user';

  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';

  /// Plain-text mirror of the keystore-held device id.
  ///
  /// The backend binds a session to this id, so losing it signs the user out
  /// and can read as "this account is on another device". The Android Keystore
  /// loses values often enough on older builds that the id is kept here too —
  /// it identifies an install, it is not a secret.
  static const String deviceUuidKey = 'device_uuid';
}
