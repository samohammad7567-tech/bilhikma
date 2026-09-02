import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_result.dart';
import '../models/notification_model.dart';

class NotificationsDataSource {
  const NotificationsDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<List<NotificationModel>> fetchNotifications({int perPage = 50}) async {
    final PaginatedResult<NotificationModel> page = await client
        .getPage<NotificationModel>(
          ApiEndpoints.notifications,
          NotificationModel.fromJson,
          queryParameters: <String, dynamic>{'per_page': perPage.clamp(1, 50)},
        );

    return page.items;
  }

  Future<void> markRead(int notificationId) =>
      client.post(ApiEndpoints.notificationRead(notificationId));
}
