import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bilhikma_app.dart';
import 'core/app/app_bootstrap.dart';
import 'core/app/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/device_info_service.dart';
import 'core/services/device_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/screen_capture_policy.dart';
import 'core/services/screen_capture_service.dart';
import 'core/utils/cache_util.dart';

void main() {
  // The zone is the last line of defence: an error thrown from a future nobody
  // awaited during startup is reported here instead of taking the launch down
  // silently.
  runZonedGuarded(_startApp, AppBootstrap.reportFatal);
}

/// Brings the app up so that it always reaches [runApp].
///
/// Each step below can fail on a real device — a corrupted Android Keystore, a
/// preferences file the OS could not read, an unreachable host — and none of
/// them is worth refusing to start over. [AppBootstrap.runStep] isolates and
/// time-boxes each one, so a failure costs that feature and nothing more.
Future<void> _startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Installed first, so it already covers the startup steps that follow.
  AppBootstrap.installErrorHandlers();
  Bloc.observer = const AppBlocObserver();

  // Ordered by dependency, not importance: preferences hold the session token,
  // the token and the device headers are read when the service locator builds
  // the Dio instance.
  await AppBootstrap.runStep('preferences', CacheUtil.init);
  await AppBootstrap.runStep(
    'localization',
    EasyLocalization.ensureInitialized,
  );
  // Longer than the default: this step reads and may rewrite the keychain, and
  // each of those carries its own timeout. The budget here has to outlast the
  // sum of them, or a recoverable keystore failure would lose the device id.
  await AppBootstrap.runStep(
    'device_identity',
    DeviceService.ensureInitialized,
    timeout: const Duration(seconds: 25),
  );
  await AppBootstrap.runStep('service_locator', setupServiceLocator);

  // Needs the device info gathered by the step above, and has to be set before
  // the first frame decodes an image.
  AppBootstrap.tuneImageCache(isLowEndDevice: DeviceInfoService.isLowEndDevice);

  AppBootstrap.runSyncStep(
    'lifecycle',
    AppLifecycleService.instance.initialize,
  );
  AppBootstrap.runSyncStep('capture_watch', () {
    ScreenCaptureService.instance.attach(getIt());
    ScreenCapturePolicy.initialize();
  });
  await AppBootstrap.runStep('capture_policy', ScreenCapturePolicy.restore);

  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: const BilhikmaApp(),
    ),
  );

  // Deliberately after the first frame and deliberately not awaited. Push
  // needs Google Play services and the network, and on an older phone either
  // can take half a minute or fail outright; none of that may delay the UI.
  unawaited(
    AppBootstrap.runStep(
      'push_notifications',
      PushNotificationService.ensureInitialized,
      timeout: const Duration(seconds: 90),
    ),
  );
}
