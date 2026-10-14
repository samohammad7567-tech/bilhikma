class CacheKeys {
  CacheKeys._();
  static const String isDark = 'isDark';
  static const String fontScale = 'font_scale';
  static const String sleepTimerMinutes = 'sleep_timer_minutes';
  /// Audio and video each keep their own playback speed. The old shared key is
  /// still read once, so a speed chosen before the split is not lost.
  static const String legacyPlaybackSpeed = 'playback_speed';
  static const String audioPlaybackSpeed = 'audio_playback_speed';
  static const String videoPlaybackSpeed = 'video_playback_speed';
  static const String rememberMeKey = 'remember_me';
  static const String rememberedIdentifierKey = 'remembered_identifier';
  static const String rememberedMethodKey = 'remembered_login_method';

  static const String cachedUserKey = 'cached_user';
  static const String pdfReadingPositions = 'pdf_reading_positions';
  static const String pdfPageLayout = 'pdf_page_layout';

  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';
  static const String deviceUuidKey = 'device_uuid';
}
