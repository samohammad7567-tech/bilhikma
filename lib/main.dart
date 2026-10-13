import 'dart:async';

import 'package:bilhikma/core/constants/cache_keys.dart';
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
  runZonedGuarded(_startApp, AppBootstrap.reportFatal);
}

Future<void> _startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBootstrap.installErrorHandlers();
  Bloc.observer = const AppBlocObserver();
  await AppBootstrap.runStep('preferences', CacheUtil.init);
  await AppBootstrap.runStep(
    'localization',
    EasyLocalization.ensureInitialized,
  );
  await AppBootstrap.runStep(
    'device_identity',
    DeviceService.ensureInitialized,
    timeout: const Duration(seconds: 25),
  );
  await AppBootstrap.runStep('service_locator', setupServiceLocator);
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
  print(CacheUtil.get(key: CacheKeys.deviceUuidKey));
  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: const BilhikmaApp(),
    ),
  );
  unawaited(
    AppBootstrap.runStep(
      'push_notifications',
      PushNotificationService.ensureInitialized,
      timeout: const Duration(seconds: 90),
    ),
  );
}
