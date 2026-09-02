import '../routing/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../constants/api_endpoints.dart';
import '../di/service_locator.dart';
import '../services/device_service.dart';
import '../services/device_session_service.dart';

class DeviceInterceptor extends Interceptor {
  const DeviceInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (DeviceService.isInitialized) {
      options.headers.addAll(DeviceService.headers);
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!DeviceSessionService.isDeviceConflict(err)) {
      handler.next(err);
      return;
    }
    if (_isLoginRequest(err.requestOptions)) {
      handler.next(err);
      return;
    }

    await DeviceSessionService.clear();

    final navigator = getIt<GlobalKey<NavigatorState>>().currentState;

    navigator?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

    handler.reject(err);
  }

  bool _isLoginRequest(RequestOptions options) {
    return '/${options.path.replaceFirst(RegExp(r'^/'), '')}' ==
        ApiEndpoints.login;
  }
}
