import '../constants/app_assets.dart';
import '../network/json_reader.dart';
import 'notification_tone_enum.dart';

enum NotificationKind {
  newContent('new_content', tone: NotificationTone.lesson),
  liveSession('live_session', tone: NotificationTone.lesson),
  liveReminder('live_reminder', tone: NotificationTone.lesson),
  enrollmentApproved('enrollment_approved', tone: NotificationTone.lesson),
  accountStatus('account_status', tone: NotificationTone.alert),
  inactivityWarning('inactivity_warning', tone: NotificationTone.alert),
  adminAnnouncement(
    'admin_announcement',
    tone: NotificationTone.administrative,
  ),
  custom('custom', tone: NotificationTone.administrative);

  const NotificationKind(this.key, {required this.tone});

  final String key;
  final NotificationTone tone;

  /// Category name shown on the card, so the family is readable without
  /// relying on colour.
  String get labelKey => switch (this) {
    NotificationKind.newContent => 'notification_kind_new_content',
    NotificationKind.liveSession => 'notification_kind_live_session',
    NotificationKind.liveReminder => 'notification_kind_live_reminder',
    NotificationKind.enrollmentApproved =>
      'notification_kind_enrollment_approved',
    NotificationKind.accountStatus => 'notification_kind_account_status',
    NotificationKind.inactivityWarning =>
      'notification_kind_inactivity_warning',
    NotificationKind.adminAnnouncement =>
      'notification_kind_admin_announcement',
    NotificationKind.custom => 'notification_kind_custom',
  };

  String get imagePath => switch (this) {
    NotificationKind.newContent => AppAssets.assetsNewContentNotification,
    NotificationKind.liveSession => AppAssets.assetsLiveSessionNotification,
    NotificationKind.liveReminder =>
      AppAssets.assetsInstantReminderNotification,
    NotificationKind.enrollmentApproved =>
      AppAssets.assetsApprovalOfRegistrationNotification,
    NotificationKind.accountStatus => AppAssets.assetsAccountStatusNotification,
    NotificationKind.inactivityWarning => AppAssets.assetsWarningNotification,
    NotificationKind.adminAnnouncement => AppAssets.assetsAdministrativeNotice,
    NotificationKind.custom => AppAssets.assetsCustomNotification,
  };

  /// Artwork that already carries its own rounded tile, drawn whole rather
  /// than as a glyph inside one.
  bool get hasOwnTile => switch (this) {
    NotificationKind.adminAnnouncement || NotificationKind.custom => true,
    _ => false,
  };

  /// Every glyph is authored as flat artwork on transparency, so it takes
  /// the tone colour and stays legible in both themes. The two that bring
  /// their own tile are opaque — tinting those would flood the whole square.
  bool get hasMonochromeIcon => !hasOwnTile;

  static NotificationKind fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return NotificationKind.values.firstWhere(
      (NotificationKind kind) => kind.key == key,
      orElse: () => NotificationKind.custom,
    );
  }
}
