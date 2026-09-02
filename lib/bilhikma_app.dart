import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app/cubit/app_preferences_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/routing/keyboard_dismiss_observer.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/app_screen_util.dart';
import 'core/widgets/app_chrome.dart';

class BilhikmaApp extends StatelessWidget {
  const BilhikmaApp({super.key});

  static final List<NavigatorObserver> _navigatorObservers =
      <NavigatorObserver>[KeyboardDismissObserver()];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppPreferencesCubit>.value(
      value: getIt<AppPreferencesCubit>(),
      child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        builder: (BuildContext context, AppPreferencesState state) {
          final AppPreferencesCubit preferences = context
              .read<AppPreferencesCubit>();

          return ScreenUtilInit(
            designSize: AppScreenUtil.designSize,
            minTextAdapt: AppScreenUtil.minTextAdapt,
            splitScreenMode: AppScreenUtil.splitScreenMode,
            builder: (_, _) => MaterialApp(
              navigatorKey: getIt<GlobalKey<NavigatorState>>(),
              onGenerateRoute: AppRouter.onGenerateRoute,
              navigatorObservers: _navigatorObservers,
              initialRoute: AppRoutes.splash,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: preferences.isDark ? ThemeMode.dark : ThemeMode.light,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              builder: (BuildContext context, Widget? child) =>
                  AppChrome(fontScale: preferences.fontScale, child: child),
            ),
          );
        },
      ),
    );
  }
}
