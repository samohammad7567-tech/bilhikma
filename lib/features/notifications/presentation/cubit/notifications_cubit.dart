import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/routing/notification_destination.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../live_sessions/data/repos/live_sessions_repo.dart';
import '../../data/models/notification_model.dart';
import '../../data/repos/notifications_repo.dart';
import '../refactor/notification_day_group.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    this.repo = const NotificationsRepo(),
    this.liveRepo = const LiveSessionsRepo(),
  }) : super(const NotificationsState()) {
    loadNotifications();
  }

  final NotificationsRepo repo;
  final LiveSessionsRepo liveRepo;

  final Set<int> _pendingReads = <int>{};

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> markSeen(int notificationId) => markRead(notificationId);

  void selectFilter(NotificationsFilter filter) {
    if (filter == state.filter) return;

    emit(
      state.copyWith(
        filter: filter,
        unreadView: filter == NotificationsFilter.unread
            ? _currentUnread()
            : const <int>{},
      ),
    );
  }

  /// Where tapping [item] should go, after marking it read.
  ///
  /// Returns null when the notification names no screen — its message is all
  /// there is, and the caller shows that instead.
  Future<NotificationDestination?> open(NotificationModel item) async {
    unawaited(markRead(item.id));

    if (item.payload.hasLiveSession) {
      return _openLiveSession(item);
    }

    return NotificationDestination.resolve(
      kind: item.kind,
      payload: item.payload,
      deepLink: item.deepLink,
    );
  }

  /// The player needs the session itself, which only a fetch can supply.
  /// A session that cannot be loaded — finished, pulled, offline — falls
  /// back to the sessions list rather than failing the tap.
  Future<NotificationDestination> _openLiveSession(
    NotificationModel item,
  ) async {
    emit(state.copyWith(openingId: item.id, clearError: true));

    try {
      final LiveSessionModel session = await liveRepo.fetchSession(
        item.payload.liveSessionId,
      );
      if (isClosed) return const NotificationDestination(AppRoutes.live);

      emit(state.copyWith(clearOpening: true));

      return NotificationDestination(AppRoutes.livePlayer, arguments: session);
    } catch (_) {
      if (isClosed) return const NotificationDestination(AppRoutes.live);

      emit(state.copyWith(clearOpening: true));

      return const NotificationDestination(AppRoutes.live);
    }
  }

  Set<int> _currentUnread() => state.notifications
      .where((NotificationModel item) => !item.isRead)
      .map((NotificationModel item) => item.id)
      .toSet();

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

      // A reload replaces the rows the unread tab was holding open.
      if (state.isUnreadTab) {
        emit(state.copyWith(unreadView: _currentUnread()));
      }
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
