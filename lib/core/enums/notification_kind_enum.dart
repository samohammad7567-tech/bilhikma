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
    NotificationKind.newContent => AppAssets.assetsBookIcon,
    NotificationKind.liveSession => AppAssets.assetsLive,
    NotificationKind.liveReminder => AppAssets.assetsLive,
    NotificationKind.enrollmentApproved => AppAssets.assetsAccountAccepted,
    NotificationKind.accountStatus => AppAssets.assetsAccountRejected,
    NotificationKind.inactivityWarning => AppAssets.assetsPending,
    NotificationKind.adminAnnouncement => AppAssets.assetsNotificationIcon,
    NotificationKind.custom => AppAssets.assetsNotificationIcon,
  };

  /// Single-colour artwork, which is tinted to the tone so it stays visible.
  /// The rest are full-colour illustrations and are drawn as authored.
  bool get hasMonochromeIcon => switch (this) {
    NotificationKind.liveSession ||
    NotificationKind.liveReminder ||
    NotificationKind.adminAnnouncement ||
    NotificationKind.custom => true,
    _ => false,
  };

  static NotificationKind fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return NotificationKind.values.firstWhere(
      (NotificationKind kind) => kind.key == key,
      orElse: () => NotificationKind.custom,
    );
  }
}
