import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_logger.dart';

class AppBootstrap {
  AppBootstrap._();

  static const String _logName = 'bootstrap';
  static const Duration stepTimeout = Duration(seconds: 12);

  static final List<String> _failedSteps = <String>[];
  static List<String> get failedSteps =>
      List<String>.unmodifiable(_failedSteps);

  static bool didStepFail(String name) => _failedSteps.contains(name);
  static void installErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter framework error in ${details.library ?? 'unknown library'}',
        name: _logName,
        error: details.exception,
        stackTrace: details.stack,
      );
      if (kDebugMode) FlutterError.presentError(details);
    };
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

  static void reportFatal(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Fatal error escaped the startup zone',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }

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
