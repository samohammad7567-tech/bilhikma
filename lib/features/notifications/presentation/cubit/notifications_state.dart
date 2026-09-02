part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, success, failure }

final class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const <NotificationModel>[],
    this.errorKey,
  });

  final NotificationsStatus status;
  final List<NotificationModel> notifications;
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

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    String? errorKey,
    bool clearError = false,
  }) => NotificationsState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}
