import '../constants/api_endpoints.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/device_interceptor.dart';
import 'device_service.dart';
import '../utils/cache_util.dart';
import 'package:dio/dio.dart';

class DioService {
  static Dio? dio;

  /// Dio's own default for every timeout is `null`, which means wait forever.
  /// Without these a single unreachable host holds the UI indefinitely — the
  /// splash screen used to sit there until Android's ANR killer stepped in,
  /// which users read as the app crashing on launch.
  ///
  /// Sized for a slow mobile connection rather than for office Wi-Fi: better
  /// to let a genuinely slow request finish than to fail a user on 3G.
  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _receiveTimeout = Duration(seconds: 40);
  static const Duration _sendTimeout = Duration(seconds: 40);

  static String _storedToken() {
    final Object? token = CacheUtil.get(key: 'token');
    print(token);
    return token is String ? token : '';
  }

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',

          'Authorization': 'Bearer ${_storedToken()}',
          ...DeviceService.headers,
        },
      ),
    );
    dio!.interceptors.add(const DeviceInterceptor());
    dio!.interceptors.add(AuthInterceptor(dio: dio!));
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio!.get(path, queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {dynamic data}) async {
    return await dio!.post(path, data: data);
  }

  static Future<Response> put(String path, {dynamic data}) async {
    return await dio!.put(path, data: data);
  }

  static Future<Response> patch(String path, {dynamic data}) async {
    return await dio!.patch(path, data: data);
  }

  static Future<Response> delete(String path) async {
    return await dio!.delete(path);
  }

  static void updateToken(String token) {
    dio?.options.headers['Authorization'] = 'Bearer $token';
  }
}
