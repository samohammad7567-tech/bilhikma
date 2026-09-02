import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../features/auth/login/data/models/refresh_token_response_model.dart';
import '../constants/api_endpoints.dart';
import '../di/service_locator.dart';
import '../routing/app_routes.dart';
import '../services/device_service.dart';
import '../services/device_session_service.dart';
import '../utils/cache_util.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  Future<String?>? _refreshFuture;

  bool _isLoggingOut = false;

  AuthInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final path = '/${requestOptions.path.replaceFirst(RegExp(r'^/+'), '')}';

    final isRefreshEndpoint = path == ApiEndpoints.refreshToken;

    final isLoginEndpoint = path == ApiEndpoints.login;

    final isAuthEndpoint = isRefreshEndpoint || isLoginEndpoint;

    final statusCode = err.response?.statusCode;

    if (statusCode == 403 && !isAuthEndpoint) {
      return handler.reject(err);
    }

    if (statusCode != 401) {
      return handler.next(err);
    }

    if (isAuthEndpoint) {
      if (isRefreshEndpoint) {
        await _handleLogoutOnce();
      }

      return handler.reject(err);
    }

    final alreadyRetried = requestOptions.extra['auth_retry'] == true;

    if (alreadyRetried) {
      await _handleLogoutOnce();
      return handler.reject(err);
    }

    requestOptions.extra['auth_retry'] = true;

    try {
      final newAccessToken = await _getOrCreateRefresh();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _handleLogoutOnce();
        return handler.reject(err);
      }

      final response = await _retryRequest(requestOptions, newAccessToken);

      return handler.resolve(response);
    } catch (e) {
      await _handleLogoutOnce();
      return handler.reject(err);
    }
  }

  Future<String?> _getOrCreateRefresh() {
    final existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final refreshFuture = _refreshAccessToken();

    _refreshFuture = refreshFuture;

    refreshFuture.whenComplete(() {
      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }
    });

    return refreshFuture;
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = CacheUtil.get(key: 'refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final accessToken = CacheUtil.get(key: 'token');

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...DeviceService.headers,
          },
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null && accessToken.isNotEmpty)
              'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;

      if (body is! Map<String, dynamic>) {
        return null;
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        return null;
      }

      final session = RefreshTokenResponseModel.fromData(data);

      if (!session.hasSession) {
        return null;
      }

      final newAccessToken = session.accessToken;
      final newRefreshToken = session.refreshToken ?? refreshToken;

      await CacheUtil.setString(key: 'token', value: newAccessToken);

      await CacheUtil.setString(key: 'refresh_token', value: newRefreshToken);

      await DeviceSessionService.bind(newAccessToken);

      dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

      return newAccessToken;
    } on DioException catch (e) {
      debugPrint(
        'Token refresh failed: '
        '${e.response?.statusCode}',
      );

      return null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');

      return null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);

    headers['Authorization'] = 'Bearer $accessToken';

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: headers,

        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: {...requestOptions.extra, 'auth_retry': true},
        validateStatus: requestOptions.validateStatus,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      ),
    );
  }

  Future<void> _handleLogoutOnce() async {
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;

    try {
      await DeviceSessionService.clear();

      final navigator = getIt<GlobalKey<NavigatorState>>().currentState;

      if (navigator == null) {
        return;
      }

      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } finally {
      _isLoggingOut = false;
    }
  }
}
