import 'package:bilhikma/core/network/api_envelope.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _refusal(int statusCode, [Object? body]) => DioException(
  requestOptions: RequestOptions(path: '/user/content'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/user/content'),
    statusCode: statusCode,
    data: body,
  ),
);

ApiEnvelope _envelope(int statusCode, {String? message}) =>
    ApiEnvelope(statusCode: statusCode, message: message);

void main() {
  group('the codes that end a session', () {
    test('a refusal the session cannot survive ends it', () {
      for (final int code in ErrorMapper.sessionEndedCodes) {
        expect(
          ErrorMapper.sessionIsOver(_refusal(code)),
          isTrue,
          reason: '$code',
        );
      }
    });

    test('every one of them tells the student the same thing', () {
      for (final int code in ErrorMapper.sessionEndedCodes) {
        expect(
          ErrorMapper.map(_refusal(code)),
          ErrorMapper.sessionEndedKey,
          reason: '$code',
        );
      }
    });

    test('the body is not consulted, whatever it happens to say', () {
      // The point of keying off the code: these bodies are all different, the
      // verdict is not. A state the dashboard invents next month arrives in
      // exactly this shape and still ends the session.
      final List<Map<String, dynamic>> bodies = <Map<String, dynamic>>[
        <String, dynamic>{'message': 'Your account has been suspended.'},
        <String, dynamic>{'account_status': 'archived'},
        <String, dynamic>{'account_status': 'active'},
        <String, dynamic>{'status_code': 0, 'data': null},
        <String, dynamic>{},
      ];

      for (final Map<String, dynamic> body in bodies) {
        expect(ErrorMapper.sessionIsOver(_refusal(403, body)), isTrue,
            reason: '$body');
      }
    });

    test('a code in the body ends it too, on an otherwise fine response', () {
      // This API answers 200 and puts its own code in the envelope, so that
      // code has to carry the same weight as the transport one.
      final AppException error = ErrorMapper.fromEnvelope(
        _envelope(403),
        statusCode: 200,
      );

      expect(error.endsSession, isTrue);
      expect(error.key, ErrorMapper.sessionEndedKey);
    });
  });

  group('the codes that leave a session alone', () {
    test('an ordinary failure is not a sign-out', () {
      const Map<int, String> others = <int, String>{
        400: 'invalid_credentials',
        404: 'not_found',
        422: 'validation_error',
        429: 'too_many_requests',
        500: 'server_error',
        503: 'server_error',
      };

      for (final MapEntry<int, String> entry in others.entries) {
        final AppException error = ErrorMapper.toException(
          _refusal(entry.key),
        );

        expect(error.endsSession, isFalse, reason: '${entry.key}');
        expect(error.key, entry.value, reason: '${entry.key}');
      }
    });

    test('a dead network is not a sign-out', () {
      final DioException offline = DioException(
        requestOptions: RequestOptions(path: '/user/content'),
        type: DioExceptionType.connectionError,
      );

      expect(ErrorMapper.sessionIsOver(offline), isFalse);
      expect(ErrorMapper.map(offline), 'no_internet_connection');
    });

    test('a session claimed by another device keeps its own message', () {
      final DioException conflict = _refusal(409, <String, dynamic>{
        'code': 'device_already_linked',
      });

      expect(ErrorMapper.map(conflict), 'device_already_linked');
      expect(ErrorMapper.sessionIsOver(conflict), isFalse);
    });

    test('a successful envelope code says nothing about the session', () {
      final AppException error = ErrorMapper.fromEnvelope(
        _envelope(ApiEnvelope.successCode),
        statusCode: 200,
      );

      expect(error.endsSession, isFalse);
    });
  });

  group('what the failure carries', () {
    test('the message and field errors survive the mapping', () {
      final AppException error = ErrorMapper.toException(
        _refusal(422, <String, dynamic>{
          'message': 'البيانات غير صحيحة',
          'status_code': 0,
          'errors': <String, dynamic>{
            'phone': <String>['رقم الهاتف مستخدم'],
          },
        }),
      );

      expect(error.key, 'validation_error');
      expect(error.message, 'البيانات غير صحيحة');
      expect(error.errorsFor('phone'), <String>['رقم الهاتف مستخدم']);
      expect(error.statusCode, 422);
    });

    test('an exception already mapped is handed back untouched', () {
      const AppException original = AppException(
        'media_link_expired',
        statusCode: 403,
      );

      expect(ErrorMapper.toException(original), same(original));

      // A data source that raises its own exception for a 403 keeps saying
      // what it meant: nothing re-reads the code behind its back.
      expect(original.endsSession, isFalse);
    });

    test('anything unrecognised is a generic failure', () {
      expect(ErrorMapper.map(Exception('boom')), 'something_went_wrong');
      expect(ErrorMapper.sessionIsOver(Exception('boom')), isFalse);
    });
  });
}
