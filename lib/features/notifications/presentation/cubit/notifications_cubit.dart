import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/routing/notification_destination.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/app_lifecycle_service.dart';
import '../../../../core/services/device_session_service.dart';
import '../../../../core/services/push_event_bus.dart';
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
    _listenForNewNotifications();
    loadNotifications();
  }

  final NotificationsRepo repo;
  final LiveSessionsRepo liveRepo;

  final Set<int> _pendingReads = <int>{};

  StreamSubscription<Map<String, dynamic>>? _pushSubscription;
  StreamSubscription<void>? _resumeSubscription;

  bool _isFetching = false;

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load();
  }

  Future<void> refresh() => _load();

  /// Keeps the list and the unread badge live: a push that arrives while the
  /// app is running, a tapped push, or a return to the foreground all pull the
  /// newest notifications without touching the visible content first.
  void _listenForNewNotifications() {
    _pushSubscription = PushEventBus.instance.stream.listen(
      (Map<String, dynamic> _) => _refreshInBackground(),
    );

    _resumeSubscription = AppLifecycleService.instance.onResumed.listen(
      (void _) => _refreshInBackground(),
    );
  }

  /// Signing out leaves this cubit alive in the service locator, so both
  /// subscriptions outlive the session they were opened for. Asking for a
  /// signed-out student's notifications earns a 401, which the auth
  /// interceptor reads as an expired session and announces on the login
  /// screen they are already looking at.
  void _refreshInBackground() {
    if (!DeviceSessionService.hasSession) return;

    unawaited(_load(silent: true));
  }

  @override
  Future<void> close() async {
    await _pushSubscription?.cancel();
    await _resumeSubscription?.cancel();

    return super.close();
  }

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

  Future<void> _load({bool silent = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final List<NotificationModel> notifications = await repo
          .fetchNotifications();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: _keepPendingReads(notifications),
          clearError: true,
        ),
      );
      if (state.isUnreadTab) {
        emit(state.copyWith(unreadView: _currentUnread()));
      }
    } on AppException catch (error) {
      _emitLoadFailure(error.key, silent);
    } catch (error) {
      _emitLoadFailure(ErrorMapper.map(error), silent);
    } finally {
      _isFetching = false;
    }
  }

  /// A background refresh that fails keeps the list exactly as it is: the user
  /// did not ask for it, so it must not replace content or raise a toast.
  void _emitLoadFailure(String errorKey, bool silent) {
    if (isClosed) return;
    if (silent && state.notifications.isNotEmpty) return;

    emit(
      state.copyWith(status: NotificationsStatus.failure, errorKey: errorKey),
    );
  }

  /// Reads that are still being sent to the backend stay read locally, so a
  /// refresh landing mid-flight never makes an opened notification unread.
  List<NotificationModel> _keepPendingReads(
    List<NotificationModel> notifications,
  ) {
    if (_pendingReads.isEmpty) return notifications;

    return notifications
        .map(
          (NotificationModel item) =>
              _pendingReads.contains(item.id) ? item.withRead(true) : item,
        )
        .toList(growable: false);
  }
}
