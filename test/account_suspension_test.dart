import 'package:bilhikma/core/enums/account_status_enum.dart';
import 'package:bilhikma/core/models/auth_user_model.dart';
import 'package:bilhikma/core/services/account_suspension_service.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _refusal(int statusCode, Object? body) => DioException(
  requestOptions: RequestOptions(path: '/user/content'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/user/content'),
    statusCode: statusCode,
    data: body,
  ),
);

void main() {
  group('a refusal that means the account was suspended', () {
    test('is read from an explicit flag', () {
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{
            'status_code': 0,
            'data': <String, dynamic>{'account_suspended': true},
          }),
        ),
        isTrue,
      );
    });

    test('is read from a status code the API sends', () {
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{'code': 'ACCOUNT_SUSPENDED'}),
        ),
        isTrue,
      );
    });

    test('is read from the refusal message in either language', () {
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{
            'message': 'Your account has been suspended.',
            'status_code': 0,
          }),
        ),
        isTrue,
      );
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{
            'message': 'تم إيقاف حسابك، يرجى التواصل مع الإدارة',
            'status_code': 0,
          }),
        ),
        isTrue,
      );
    });

    test('maps to one stable error key', () {
      expect(
        ErrorMapper.map(
          _refusal(403, <String, dynamic>{'code': 'account_suspended'}),
        ),
        'suspended_account',
      );
    });
  });

  group('a refusal that means something else', () {
    test('leaves a locked lesson alone', () {
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{
            'message': 'Finish the previous lesson to unlock this one.',
            'status_code': 0,
          }),
        ),
        isFalse,
      );
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(403, <String, dynamic>{
            'message': 'هذا المحتوى غير متاح في صفك',
            'status_code': 0,
          }),
        ),
        isFalse,
      );
    });

    test('leaves other status codes alone', () {
      expect(
        AccountSuspensionService.indicatesSuspension(
          _refusal(401, <String, dynamic>{'code': 'account_suspended'}),
        ),
        isFalse,
      );
    });
  });

  group('pushes', () {
    test('sign out only on a machine marker', () {
      expect(
        AccountSuspensionService.isSuspensionPush(<String, dynamic>{
          'type': 'account_status',
          'status': 'suspended',
        }),
        isTrue,
      );
      expect(
        AccountSuspensionService.isSuspensionPush(<String, dynamic>{
          'type': 'account_status',
          'message': 'تم إلغاء إيقاف حسابك',
        }),
        isFalse,
      );
    });

    test('an account announcement asks the API to confirm', () {
      expect(
        AccountSuspensionService.isAccountStatusPush(<String, dynamic>{
          'type': 'account_status',
        }),
        isTrue,
      );
      expect(
        AccountSuspensionService.isAccountStatusPush(<String, dynamic>{
          'type': 'new_content',
        }),
        isFalse,
      );
    });
  });

  group('the signed-in user', () {
    test('carries the status the API sent', () {
      final AuthUserModel user = AuthUserModel.fromJson(<String, dynamic>{
        'id': 9,
        'full_name': 'أحمد محمد',
        'status': 'suspended',
      });

      expect(user.status, AccountStatus.suspended);
      expect(user.isSuspended, isTrue);
    });

    test('falls back to active when the field is missing or unknown', () {
      expect(
        AuthUserModel.fromJson(<String, dynamic>{
          'id': 9,
          'full_name': 'أحمد محمد',
        }).isSuspended,
        isFalse,
      );
      expect(
        AuthUserModel.fromJson(<String, dynamic>{
          'id': 9,
          'full_name': 'أحمد محمد',
          'status': 'something_new',
        }).status,
        AccountStatus.active,
      );
    });

    test('round-trips through the cache', () {
      final AuthUserModel user = AuthUserModel.fromJson(<String, dynamic>{
        'id': 9,
        'full_name': 'أحمد محمد',
        'status': 'suspended',
      });

      expect(AuthUserModel.fromJson(user.toJson()).isSuspended, isTrue);
    });
  });
}
