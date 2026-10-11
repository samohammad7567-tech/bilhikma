import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_logger.dart';

/// Owns everything that has to happen around the first frame, and guarantees
/// that no single failure can stop the app from starting.
///
/// Why this exists: every `await` placed before `runApp` is a chance never to
/// reach `runApp` at all. On an older phone a stale Google Play services, a
/// corrupted Android keystore or a black-holed DNS is routine, and any one of
/// them throwing leaves the user staring at the native splash bitmap until
/// Android kills the process — which reads as "the app crashes on open".
///
/// So every startup step is isolated, time-boxed and non-fatal: a step that
/// fails is recorded and the app starts without it.
class AppBootstrap {
  AppBootstrap._();

  static const String _logName = 'bootstrap';

  /// A step that has not answered by now is abandoned. It is deliberately
  /// generous — old devices really are this slow — and exists only to convert
  /// an indefinite hang (unreachable host, wedged platform channel) into a
  /// recoverable failure.
  static const Duration stepTimeout = Duration(seconds: 12);

  static final List<String> _failedSteps = <String>[];

  /// Startup steps that did not complete, in the order they failed. Read this
  /// when deciding whether a feature can be offered at all.
  static List<String> get failedSteps =>
      List<String>.unmodifiable(_failedSteps);

  static bool didStepFail(String name) => _failedSteps.contains(name);

  /// Sends framework, platform and build errors somewhere visible instead of
  /// letting them tear the isolate down.
  ///
  /// Call this immediately after `ensureInitialized()` — before any other
  /// startup work, so that work is already covered.
  static void installErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter framework error in ${details.library ?? 'unknown library'}',
        name: _logName,
        error: details.exception,
        stackTrace: details.stack,
      );

      // The console dump is noise in a user's logcat and useful only while
      // developing, so the full presentation stays in debug.
      if (kDebugMode) FlutterError.presentError(details);
    };

    // Errors raised on the platform side, or thrown by a future nobody is
    // awaiting, reach the engine rather than the framework. Returning true
    // marks them handled so the engine does not take the process down.
    ui.PlatformDispatcher.instance.onError =
        (Object error, StackTrace stackTrace) {
          AppLogger.error(
            'Unhandled error outside the framework',
            name: _logName,
            error: error,
            stackTrace: stackTrace,
          );
          return true;
        };

    // A widget that throws while building must never hand the user a red
    // screen of exception text. In release it collapses to empty space and the
    // reason goes to the log; in debug the normal red box is kept.
    if (kReleaseMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        AppLogger.error(
          'Widget build failed',
          name: _logName,
          error: details.exception,
          stackTrace: details.stack,
        );
        return const SizedBox.shrink();
      };
    }
  }

  /// Terminal handler for [runZonedGuarded]: an error that escaped every other
  /// guard. Nothing is left to recover, so the one job here is to make sure it
  /// is not lost silently.
  static void reportFatal(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Fatal error escaped the startup zone',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Runs one asynchronous startup step. Never throws and never hangs.
  ///
  /// [name] is what shows up in the log and in [failedSteps], so keep it stable
  /// and greppable.
  static Future<void> runStep(
    String name,
    Future<void> Function() step, {
    Duration timeout = stepTimeout,
  }) async {
    try {
      await step().timeout(timeout);
    } on TimeoutException {
      _recordFailure(
        name,
        'timed out after ${timeout.inSeconds}s',
        error: null,
        stackTrace: null,
      );
    } catch (error, stackTrace) {
      _recordFailure(name, 'threw', error: error, stackTrace: stackTrace);
    }
  }

  /// Runs one synchronous startup step. Same contract as [runStep]: a failure
  /// is recorded, never rethrown.
  static void runSyncStep(String name, void Function() step) {
    try {
      step();
    } catch (error, stackTrace) {
      _recordFailure(name, 'threw', error: error, stackTrace: stackTrace);
    }
  }

  static void _recordFailure(
    String name,
    String what, {
    required Object? error,
    required StackTrace? stackTrace,
  }) {
    _failedSteps.add(name);
    AppLogger.error(
      'Startup step "$name" $what — starting without it',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Sizes the image cache for the device the app actually landed on.
  ///
  /// Flutter defaults to 100 MB and 1000 entries, which is more than the entire
  /// heap Android grants a process on a 1 GB phone. This app also keeps
  /// ExoPlayer, a WebView and the PDF engine resident, so the cache is trimmed
  /// to leave those room rather than racing them to the OOM killer.
  static void tuneImageCache({required bool isLowEndDevice}) {
    PaintingBinding.instance.imageCache
      ..maximumSizeBytes = (isLowEndDevice ? 24 : 56) << 20
      ..maximumSize = isLowEndDevice ? 40 : 120;

    AppLogger.info(
      'Image cache capped at '
      '${PaintingBinding.instance.imageCache.maximumSizeBytes >> 20}MB / '
      '${PaintingBinding.instance.imageCache.maximumSize} entries '
      '(low-end: $isLowEndDevice)',
      name: _logName,
    );
  }
}
