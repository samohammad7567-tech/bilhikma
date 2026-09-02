import 'package:dio/dio.dart';
import '../network/api_envelope.dart';
import '../services/device_session_service.dart';

class AppException implements Exception {
  const AppException(
    this.key, {
    this.message,
    this.errors = const <String, List<String>>{},
    this.statusCode,
    this.data,
  });

  final String key;

  final String? message;

  final Map<String, List<String>> errors;

  final int? statusCode;

  final Object? data;

  List<String> errorsFor(String field) => errors[field] ?? const <String>[];

  @override
  String toString() => 'AppException($key, message: $message)';
}

class ErrorMapper {
  ErrorMapper._();

  static String map(Object error) {
    if (error is AppException) return error.key;
    if (error is DioException) return _mapDio(error);
    return 'something_went_wrong';
  }

  static AppException toException(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final Map<String, dynamic>? body = error.response?.data is Map
          ? Map<String, dynamic>.from(error.response!.data as Map)
          : null;
      final ApiEnvelope? envelope = body == null
          ? null
          : ApiEnvelope.fromJson(body);

      return AppException(
        _mapDio(error),
        message: envelope?.message,
        errors: envelope?.errors ?? const <String, List<String>>{},
        statusCode: error.response?.statusCode,

        data: envelope?.data ?? body,
      );
    }

    return const AppException('something_went_wrong');
  }

  static AppException fromEnvelope(ApiEnvelope envelope, {int? statusCode}) =>
      AppException(
        _mapStatusCode(statusCode),
        message: envelope.message,
        errors: envelope.errors,
        statusCode: statusCode,
        data: envelope.data,
      );

  static String _mapDio(DioException error) {
    if (DeviceSessionService.isDeviceConflict(error)) {
      return 'device_already_linked';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'no_internet_connection';
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode);
      default:
        return 'something_went_wrong';
    }
  }

  static String _mapStatusCode(int? statusCode) => switch (statusCode) {
    400 => 'invalid_credentials',
    401 => 'session_expired',
    201 => 'suspended_account',

    403 => 'access_denied',
    404 => 'not_found',
    422 => 'validation_error',
    429 => 'too_many_requests',
    _ when statusCode != null && statusCode >= 500 => 'server_error',
    _ => 'something_went_wrong',
  };
}
