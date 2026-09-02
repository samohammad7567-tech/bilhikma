import '../constants/app_assets.dart';
import '../network/json_reader.dart';
import 'notification_tone_enum.dart';

enum NotificationKind {
  newContent('new_content', tone: NotificationTone.gold),
  liveSession('live_session', tone: NotificationTone.green),
  liveReminder('live_reminder', tone: NotificationTone.green),
  enrollmentApproved('enrollment_approved', tone: NotificationTone.green),
  accountStatus('account_status', tone: NotificationTone.gold),
  inactivityWarning('inactivity_warning', tone: NotificationTone.gold),
  adminAnnouncement('admin_announcement', tone: NotificationTone.gold),
  custom('custom', tone: NotificationTone.gold);

  const NotificationKind(this.key, {required this.tone});

  final String key;
  final NotificationTone tone;

  bool get isGreen => tone == NotificationTone.green;

  String get imagePath => switch (this) {
    NotificationKind.newContent => AppAssets.assetsBookIcon,
    NotificationKind.liveSession => AppAssets.assetsLive,
    NotificationKind.liveReminder => AppAssets.assetsLive,
    NotificationKind.enrollmentApproved => AppAssets.assetsAccountAccepted,
    NotificationKind.accountStatus => AppAssets.assetsAccountRejected,
    NotificationKind.inactivityWarning => AppAssets.assetsPending,
    NotificationKind.adminAnnouncement => AppAssets.assetsNotification,
    NotificationKind.custom => AppAssets.assetsNotification,
  };

  static NotificationKind fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return NotificationKind.values.firstWhere(
      (NotificationKind kind) => kind.key == key,
      orElse: () => NotificationKind.custom,
    );
  }
}
