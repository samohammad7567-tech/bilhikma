import '../data_source/notifications_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepo {
  const NotificationsRepo({this.dataSource = const NotificationsDataSource()});

  final NotificationsDataSource dataSource;

  Future<List<NotificationModel>> fetchNotifications() =>
      dataSource.fetchNotifications();

  Future<void> markRead(int notificationId) =>
      dataSource.markRead(notificationId);
}
