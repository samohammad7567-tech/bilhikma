part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, success, failure }

enum NotificationsFilter { all, unread }

final class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const <NotificationModel>[],
    this.filter = NotificationsFilter.all,
    this.unreadView = const <int>{},
    this.openingId,
    this.errorKey,
  });

  final NotificationsStatus status;
  final List<NotificationModel> notifications;

  final NotificationsFilter filter;
  final Set<int> unreadView;
  final int? openingId;

  final String? errorKey;

  bool get isFirstLoad =>
      status == NotificationsStatus.loading && notifications.isEmpty;

  bool get hasFailedOutright =>
      status == NotificationsStatus.failure && notifications.isEmpty;

  bool get isEmpty =>
      status == NotificationsStatus.success && notifications.isEmpty;

  int get unreadCount =>
      notifications.where((NotificationModel item) => !item.isRead).length;

  bool get hasUnread => unreadCount > 0;

  bool get isUnreadTab => filter == NotificationsFilter.unread;

  List<NotificationModel> get visible => isUnreadTab
      ? notifications
            .where((NotificationModel item) => unreadView.contains(item.id))
            .toList(growable: false)
      : notifications;

  List<NotificationDayGroup> get groups => NotificationDayGroup.build(visible);
  bool get hasNothingToShow =>
      status == NotificationsStatus.success && visible.isEmpty;

  bool isOpening(int id) => openingId == id;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    NotificationsFilter? filter,
    Set<int>? unreadView,
    int? openingId,
    String? errorKey,
    bool clearError = false,
    bool clearOpening = false,
  }) => NotificationsState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications,
    filter: filter ?? this.filter,
    unreadView: unreadView ?? this.unreadView,
    openingId: clearOpening ? null : openingId ?? this.openingId,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
