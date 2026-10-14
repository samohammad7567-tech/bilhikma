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
    this.endsSession = false,
  });

  final String key;

  final String? message;

  final Map<String, List<String>> errors;

  final int? statusCode;

  final Object? data;

  /// Whether the code this failure carried means the session itself is over,
  /// so the token on the device is worthless and the student has to sign in
  /// again. Decided once, in [ErrorMapper], and carried from there.
  final bool endsSession;

  List<String> errorsFor(String field) => errors[field] ?? const <String>[];

  @override
  String toString() => 'AppException($key, message: $message)';
}

class ErrorMapper {
  ErrorMapper._();

  /// The codes that say the session is finished, whatever the request was.
  ///
  /// The account's own state — `active`, `suspended`, whatever the dashboard
  /// calls it next — is deliberately never consulted. States are an
  /// administrative list that grows without the app being rebuilt, and a state
  /// this build has not heard of would otherwise read as "fine, carry on".
  /// The code the API answers with does not grow: whichever state an account
  /// is moved into, the request is refused with one of these, and that is the
  /// whole signal the app needs.
  static const Set<int> sessionEndedCodes = <int>{401, 403};

  /// What a student is told when the session is dropped. One notice for every
  /// code above, so a new state on the dashboard needs no new wording here.
  static const String sessionEndedKey = 'session_expired';

  /// Whether [statusCode] is one of the codes that ends the session.
  static bool endsSession(int? statusCode) =>
      statusCode != null && sessionEndedCodes.contains(statusCode);

  /// Whether [error] is a refusal the session cannot survive.
  static bool sessionIsOver(Object error) => toException(error).endsSession;

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

      final int? statusCode = error.response?.statusCode;

      return AppException(
        _mapDio(error),
        message: envelope?.message,
        errors: envelope?.errors ?? const <String, List<String>>{},
        statusCode: statusCode,

        data: envelope?.data ?? body,
        endsSession: endsSession(
          _failingCode(
            statusCode,
            envelope?.statusCode ?? ApiEnvelope.successCode,
          ),
        ),
      );
    }

    return const AppException('something_went_wrong');
  }

  static AppException fromEnvelope(ApiEnvelope envelope, {int? statusCode}) {
    final int? code = _failingCode(statusCode, envelope.statusCode);

    return AppException(
      _mapStatusCode(code),
      message: envelope.message,
      errors: envelope.errors,
      statusCode: statusCode,
      data: envelope.data,
      endsSession: endsSession(code),
    );
  }

  /// The code a failure is read by.
  ///
  /// An envelope that reaches here has already failed, so a transport code in
  /// the 2xx range says nothing about why — the code the API put in the body
  /// is the one that does, and it is the one the session is decided on.
  static int? _failingCode(int? transportCode, int envelopeCode) {
    if (transportCode != null && transportCode >= 300) return transportCode;
    if (envelopeCode == ApiEnvelope.successCode) return transportCode;

    return envelopeCode;
  }

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

  static String _mapStatusCode(int? statusCode) {
    if (endsSession(statusCode)) return sessionEndedKey;

    return switch (statusCode) {
      400 => 'invalid_credentials',
      404 => 'not_found',
      422 => 'validation_error',
      429 => 'too_many_requests',
      _ when statusCode != null && statusCode >= 500 => 'server_error',
      _ => 'something_went_wrong',
    };
  }
}
