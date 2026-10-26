import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bilhikma_app.dart';
import 'core/app/bloc/app_bloc_observer.dart';
import 'core/app/bootstart_custom.dart';
import 'core/di/service_locator.dart';
import 'core/localization/lang_keys.dart';
import 'core/services/account_status_watcher.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/device_info_service.dart';
import 'core/services/device_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/screen_capture_policy.dart';
import 'core/services/screen_capture_service.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/cache_util.dart';

void main() {
  Bootstart.configure(
    BootstartConfig(
      logger: _logStartup,
      reporter: _reportStartupProblem,
      brokenWidgetBuilder:
          (BuildContext context, FlutterErrorDetails details) =>
              BootstartBrokenWidget(message: _brokenWidgetMessage()),
    ),
  );

  // Installs the error handlers before the first startup step runs.
  Bootstart.run(_startApp);
}

Future<void> _startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  await Bootstart.runStep('preferences', CacheUtil.init);
  await Bootstart.runStep('localization', EasyLocalization.ensureInitialized);
  await Bootstart.runStep(
    'device_identity',
    DeviceService.ensureInitialized,
    timeout: const Duration(seconds: 25),
  );
  await Bootstart.runStep('service_locator', setupServiceLocator);

  Bootstart.tuneImageCache(isLowEndDevice: DeviceInfoService.isLowEndDevice);

  Bootstart.runSyncStep('lifecycle', AppLifecycleService.instance.initialize);
  Bootstart.runSyncStep(
    'account_status_watch',
    AccountStatusWatcher.initialize,
  );
  Bootstart.runSyncStep('capture_watch', () {
    ScreenCaptureService.instance.attach(getIt());
    ScreenCapturePolicy.initialize();
  });
  await Bootstart.runStep('capture_policy', ScreenCapturePolicy.restore);

  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: const BilhikmaApp(),
    ),
  );

  if (kDebugMode) {
    AppLogger.info(Bootstart.startupReport(), name: Bootstart.logName);
  }

  // Registration talks to the network, so it must never hold the first frame.
  unawaited(
    Bootstart.runStep(
      'push_notifications',
      PushNotificationService.ensureInitialized,
      timeout: const Duration(seconds: 90),
    ),
  );
}

/// Routes startup diagnostics into the app's own logger.
void _logStartup(BootstartLogRecord record) {
  switch (record.severity) {
    case BootstartSeverity.info:
      AppLogger.info(record.message, name: record.source);
    case BootstartSeverity.warning:
      AppLogger.warning(
        record.message,
        name: record.source,
        error: record.error,
      );
    case BootstartSeverity.error:
    case BootstartSeverity.fatal:
      AppLogger.error(
        record.message,
        name: record.source,
        error: record.error,
        stackTrace: record.stackTrace,
      );
  }
}

/// Where startup problems should leave the device.
///
/// Nothing is wired yet: this app has `firebase_core` but no crash-reporting
/// SDK, so every error caught during startup currently dies in the user's
/// phone. Once `firebase_crashlytics` is added and configured natively, this
/// becomes the single place that needs to change:
///
/// ```dart
/// FutureOr<void> _reportStartupProblem(BootstartLogRecord record) =>
///     FirebaseCrashlytics.instance.recordError(
///       record.error ?? record.message,
///       record.stackTrace,
///       reason: record.step,
///       fatal: record.isFatal,
///     );
/// ```
FutureOr<void> _reportStartupProblem(BootstartLogRecord record) {
  // Intentionally empty until a reporting SDK is available.
}

/// The localized line shown in release when a widget fails to build.
///
/// Resolved at build time, not at [main] time, so translations are loaded by
/// then. Guarded because a widget can fail *above* [EasyLocalization], where
/// `tr()` has nothing to read: returning null shows the icon alone, which beats
/// untranslated text — and beats a placeholder that throws and loops.
String? _brokenWidgetMessage() {
  try {
    return LangKeys.somethingWentWrong.tr();
  } catch (_) {
    return null;
  }
}
