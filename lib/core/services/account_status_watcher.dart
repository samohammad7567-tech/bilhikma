import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/data/repos/profile_repo.dart';
import '../enums/account_status_enum.dart';
import '../utils/app_logger.dart';
import 'account_state_service.dart';
import 'app_lifecycle_service.dart';
import 'device_session_service.dart';
import 'push_event_bus.dart';
import 'session_guard.dart';

/// Keeps the app honest about the state of the account it is signed in with
/// while it sits open.
///
/// Only an active account may stay in the app. Moving a student out of that
/// state is a dashboard action, so nothing on the device knows about it until
/// the platform says so. Three things tell the app, and all three end on the
/// login screen: the `account_status` push the platform sends, the 403 a
/// no-longer-active token starts answering — read in the auth interceptor —
/// and the poll this watcher runs while the app is in front, so a student
/// sitting on a screen is signed out within [pollInterval] instead of
/// whenever they next happen to tap something.
class AccountStatusWatcher {
  AccountStatusWatcher._();

  static const String _logName = 'account_status';

  /// How often the foreground poll asks the API about the account. Short
  /// enough that a state change lands while the student is still looking at
  /// the screen, long enough to cost one small request a minute.
  static const Duration pollInterval = Duration(seconds: 60);

  static const ProfileRepo _profile = ProfileRepo();

  static StreamSubscription<Map<String, dynamic>>? _pushes;

  static StreamSubscription<AppLifecycleState>? _lifecycle;

  static Timer? _poll;

  static Future<ProfileModel?>? _inFlight;

  static void initialize() {
    _pushes ??= PushEventBus.instance.stream.listen(_onPush);
    _lifecycle ??= AppLifecycleService.instance.onStateChanged.listen(
      _onLifecycleChanged,
    );

    _startPolling();
  }

  /// Reads the account as the API has it now and acts on the state it comes
  /// back with.
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
  /// answer.
  static Future<void> verifyNow() async {
    await readProfile();
  }

  static void _onPush(Map<String, dynamic> data) {
    if (!DeviceSessionService.hasSession) return;

    final AccountStatus? announced = AccountStateService.statusFromBody(data);

    if (announced != null && !announced.isActive) {
      AppLogger.info(
        'Push announced the account as ${announced.key}; signing out',
        name: _logName,
      );

      unawaited(_signOut(announced));
      return;
    }

    // An announcement that names no state can just as easily be a
    // reactivation, so the API is asked instead of guessed at.
    if (!AccountStateService.isAccountStatusPush(data)) return;

    unawaited(verifyNow());
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
      final ProfileModel profile = await _profile.fetchProfile();

      final AccountStatus? state = profile.status;
      if (state != null && !state.isActive) await _signOut(state);

      return profile;
    } catch (error) {
      // A no-longer-active token is refused, and the auth interceptor turns
      // that refusal into a forced sign-out, so there is nothing left to do
      // with the failure here beyond not crashing on it.
      AppLogger.warning(
        'Account state could not be re-read',
        name: _logName,
        error: error,
      );

      return null;
    }
  }

  static Future<void> _signOut(AccountStatus state) =>
      SessionGuard.forceSignOut(
        noticeKey: AccountStateService.noticeKeyFor(state),
      );
}
