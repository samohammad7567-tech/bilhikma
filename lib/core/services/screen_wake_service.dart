import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../utils/app_logger.dart';

/// Holds the display awake while a lesson is actually playing.
///
/// Neither `video_player` nor `youtube_player_flutter` touches the screen
/// wakelock: `video_player_android` never sets `FLAG_KEEP_SCREEN_ON` and
/// `video_player_avfoundation` never disables the iOS idle timer. The
/// `WAKE_LOCK` permission the manifest already declares is the *partial*
/// wakelock `audio_service` needs — it keeps the CPU alive, not the screen.
/// So without this service the OS display timeout fires mid-lesson while the
/// video or the audio track is still running.
///
/// Several players can be alive at the same time — the lesson video stage and
/// the lesson audio stage both use `AutomaticKeepAliveClientMixin`, and the
/// floating player outlives the screen that opened it — so requests are
/// reference counted per owner: the lock is held while *any* owner wants it
/// and released as soon as the last one lets go.
class ScreenWakeService {
  ScreenWakeService._();

  static final Set<Object> _owners = <Object>{};

  static bool _applied = false;
  static bool _isSyncing = false;

  /// Whether the platform is currently holding the screen awake for us.
  static bool get isHeld => _applied;

  /// Holds the screen awake on behalf of [owner] while [keepAwake] is true.
  ///
  /// Safe to call on every playback tick: identical requests are dropped
  /// before they reach the platform channel.
  static void request(Object owner, {required bool keepAwake}) {
    final bool changed = keepAwake ? _owners.add(owner) : _owners.remove(owner);
    if (changed) unawaited(_sync());
  }

  /// Drops [owner]'s request. Call it from `dispose()` of whatever asked, so a
  /// player that is torn down mid-playback cannot leak the lock.
  static void release(Object owner) => request(owner, keepAwake: false);

  static Future<void> _sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Loops because owners can come and go while a toggle is in flight.
      while (_owners.isNotEmpty != _applied) {
        final bool desired = _owners.isNotEmpty;
        await WakelockPlus.toggle(enable: desired);
        _applied = desired;
      }
    } catch (error) {
      AppLogger.warning(
        'Screen wakelock refused by the platform',
        name: 'wakelock',
        error: error,
      );
    } finally {
      _isSyncing = false;
    }
  }
}
