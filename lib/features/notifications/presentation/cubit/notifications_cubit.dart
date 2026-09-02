import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/notification_model.dart';
import '../../data/repos/notifications_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({this.repo = const NotificationsRepo()})
    : super(const NotificationsState()) {
    loadNotifications();
  }

  final NotificationsRepo repo;

  final Set<int> _pendingReads = <int>{};

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> markSeen(int notificationId) => markRead(notificationId);

  Future<void> markRead(int notificationId) async {
    if (_pendingReads.contains(notificationId)) return;

    final bool isUnread = state.notifications.any(
      (NotificationModel item) => item.id == notificationId && !item.isRead,
    );
    if (!isUnread) return;

    _pendingReads.add(notificationId);
    emit(state.copyWith(notifications: _withRead(notificationId, true)));

    try {
      await repo.markRead(notificationId);
      _pendingReads.remove(notificationId);
    } on AppException catch (error) {
      _pendingReads.remove(notificationId);
      if (isClosed) return;
      emit(
        state.copyWith(
          notifications: _withRead(notificationId, false),
          errorKey: error.key,
        ),
      );
    } catch (error) {
      _pendingReads.remove(notificationId);
      if (isClosed) return;
      emit(
        state.copyWith(
          notifications: _withRead(notificationId, false),
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  List<NotificationModel> _withRead(int notificationId, bool read) => state
      .notifications
      .map(
        (NotificationModel item) =>
            item.id == notificationId ? item.withRead(read) : item,
      )
      .toList(growable: false);

  Future<void> _load() async {
    try {
      final List<NotificationModel> notifications = await repo
          .fetchNotifications();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorKey: error.key,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
