import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bilhikma_app.dart';
import 'core/app/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/services/device_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/screen_capture_policy.dart';
import 'core/services/screen_capture_service.dart';
import 'core/utils/cache_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  await CacheUtil.init();
  await EasyLocalization.ensureInitialized();
  await DeviceService.ensureInitialized();
  await setupServiceLocator();
  await PushNotificationService.ensureInitialized();

  AppLifecycleService.instance.initialize();
  ScreenCaptureService.instance.attach(getIt());

  // Before the first frame: an account without permission must be listening
  // from the splash onwards, and an exempt one must not report itself.
  ScreenCapturePolicy.initialize();
  await ScreenCapturePolicy.restore();
  print(DeviceService.metadata);
  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: const BilhikmaApp(),
    ),
  );
}
