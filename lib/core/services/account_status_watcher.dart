import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/data/repos/profile_repo.dart';
import '../enums/notification_kind_enum.dart';
import '../utils/app_logger.dart';
import 'app_lifecycle_service.dart';
import 'device_session_service.dart';
import 'push_event_bus.dart';

/// Keeps the app from sitting on a session the platform has already closed.
///
/// Shutting an account out is a dashboard action, so nothing on the device
/// knows about it until the API is asked. This watcher does the asking: it
/// polls while the app is in front and asks again the moment a push says
/// something about the account, so a student sitting on a screen is dropped
/// within [pollInterval] instead of whenever they next happen to tap
/// something.
///
/// It does not decide anything. Whether the session survives is read off the
/// code the API answers with — in `ErrorMapper`, acted on by `SessionGuard` —
/// so a state the dashboard invents after this build ships still ends the
/// session, having never been named anywhere in the app.
class AccountStatusWatcher {
  AccountStatusWatcher._();

  static const String _logName = 'account_status';

  /// How often the foreground poll asks the API about the account. Short
  /// enough that a closed session lands while the student is still looking at
  /// the screen, long enough to cost one small request a minute.
  static const Duration pollInterval = Duration(seconds: 60);

  static const ProfileRepo _profile = ProfileRepo();

  static StreamSubscription<Map<String, dynamic>>? _pushes;

  static StreamSubscription<AppLifecycleState>? _lifecycle;

  static Timer? _poll;

  static Future<ProfileModel?>? _inFlight;

  /// Fields a push may name its subject in.
  static const Set<String> _typeFields = <String>{
    'type',
    'notification_type',
    'kind',
  };

  static void initialize() {
    _pushes ??= PushEventBus.instance.stream.listen(_onPush);
    _lifecycle ??= AppLifecycleService.instance.onStateChanged.listen(
      _onLifecycleChanged,
    );

    _startPolling();
  }

  /// Reads the account as the API has it now.
  ///
  /// Callers share one request: coming back to the foreground makes both the
  /// capture policy and this watcher want the profile, and the API should be
  /// asked once for it rather than twice.
  static Future<ProfileModel?> readProfile() {
    final Future<ProfileModel?>? existing = _inFlight;
    if (existing != null) return existing;

    final Future<ProfileModel?> request = _readProfile();
    _inFlight = request;

    unawaited(
      request.whenComplete(() {
        if (identical(_inFlight, request)) _inFlight = null;
      }),
    );

    return request;
  }

  /// Asks the API for the account as it stands now, without waiting on the
  /// answer. A closed session is refused, and the refusal ends it.
  static Future<void> verifyNow() async {
    await readProfile();
  }

  static void _onPush(Map<String, dynamic> data) {
    if (!DeviceSessionService.hasSession) return;

    // A push about the account carries no verdict of its own: it is as likely
    // to be a reactivation as a shut-out, and it is not the API refusing
    // anything. So it is treated as a prompt to ask, never as the answer.
    if (!_isAccountStatusPush(data)) return;

    unawaited(verifyNow());
  }

  /// True when a push is about the account itself, which is the cue to ask the
  /// API where the session stands now.
  static bool _isAccountStatusPush(Map<String, dynamic> data) {
    for (final String field in _typeFields) {
      final Object? value = data[field];
      if (value is! String) continue;

      if (NotificationKind.fromJson(value) == NotificationKind.accountStatus) {
        return true;
      }
    }

    return false;
  }

  static void _onLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The capture policy already re-reads the profile on resume, so the
      // timer starts a full interval out rather than asking again right now.
      _startPolling();
      return;
    }

    _poll?.cancel();
    _poll = null;
  }

  static void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(pollInterval, (Timer _) => unawaited(verifyNow()));
  }

  static Future<ProfileModel?> _readProfile() async {
    if (!DeviceSessionService.hasSession) return null;

    try {
      return await _profile.fetchProfile();
    } catch (error) {
      // A closed session is refused, and that refusal has already ended it by
      // the time the failure gets here, so there is nothing left to do with it
      // beyond not crashing on it.
      AppLogger.warning(
        'The account could not be re-read',
        name: _logName,
        error: error,
      );

      return null;
    }
  }
}
