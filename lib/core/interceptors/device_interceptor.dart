import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../services/device_service.dart';
import '../services/device_session_service.dart';
import '../services/session_guard.dart';
import '../utils/app_language.dart';

class DeviceInterceptor extends Interceptor {
  const DeviceInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (DeviceService.isInitialized) {
      options.headers.addAll(DeviceService.headers);
    }
    options.headers['Accept-Language'] = AppLanguage.code;

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

    await SessionGuard.forceSignOut(
      noticeKey: 'session_bound_to_another_device',
    );

    handler.reject(err);
  }

  bool _isLoginRequest(RequestOptions options) {
    return '/${options.path.replaceFirst(RegExp(r'^/'), '')}' ==
        ApiEndpoints.login;
  }
}
