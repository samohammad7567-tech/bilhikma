import 'package:bilhikma/core/enums/account_status_enum.dart';
import 'package:bilhikma/core/models/auth_user_model.dart';
import 'package:bilhikma/core/services/account_state_service.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/profile/data/models/profile_model.dart';
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
  group('a refusal that names the account', () {
    test('is read from an explicit flag', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'status_code': 0,
            'data': <String, dynamic>{'account_suspended': true},
          }),
        ),
        AccountStatus.suspended,
      );
    });

    test('is read from a status code the API sends', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{'code': 'ACCOUNT_SUSPENDED'}),
        ),
        AccountStatus.suspended,
      );
    });

    test('is read from the refusal message in either language', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'message': 'Your account has been suspended.',
            'status_code': 0,
          }),
        ),
        AccountStatus.suspended,
      );
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'message': 'تم إيقاف حسابك، يرجى التواصل مع الإدارة',
            'status_code': 0,
          }),
        ),
        AccountStatus.suspended,
      );
    });

    test('reads every state the account can be moved to', () {
      const Map<String, AccountStatus> states = <String, AccountStatus>{
        'pending': AccountStatus.pending,
        'inactive': AccountStatus.inactive,
        'deleted': AccountStatus.deleted,
      };

      for (final MapEntry<String, AccountStatus> entry in states.entries) {
        expect(
          AccountStateService.refusedState(
            _refusal(403, <String, dynamic>{'account_status': entry.key}),
          ),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('treats a state this build does not know as not active', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{'account_status': 'archived'}),
        ),
        AccountStatus.unknown,
      );
    });

    test('maps to the error key for the state it names', () {
      expect(
        ErrorMapper.map(
          _refusal(403, <String, dynamic>{'code': 'account_suspended'}),
        ),
        'suspended_account',
      );
      expect(
        ErrorMapper.map(
          _refusal(403, <String, dynamic>{'account_status': 'inactive'}),
        ),
        'inactive_account',
      );
      expect(
        ErrorMapper.map(
          _refusal(403, <String, dynamic>{'account_status': 'archived'}),
        ),
        'account_not_active',
      );
    });
  });

  group('a refusal that means something else', () {
    test('leaves a locked lesson alone', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'message': 'Finish the previous lesson to unlock this one.',
            'status_code': 0,
          }),
        ),
        isNull,
      );
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'message': 'هذا المحتوى غير متاح في صفك',
            'status_code': 0,
          }),
        ),
        isNull,
      );
    });

    test('leaves the status of another record alone', () {
      // An enrollment awaiting approval and a removed lesson both carry these
      // in a plain `status`; neither is the student account.
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'data': <String, dynamic>{'status': 'pending'},
          }),
        ),
        isNull,
      );
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{
            'data': <String, dynamic>{'status': 'approved'},
          }),
        ),
        isNull,
      );
    });

    test('leaves an active account alone', () {
      expect(
        AccountStateService.refusedState(
          _refusal(403, <String, dynamic>{'account_status': 'active'}),
        ),
        isNull,
      );
    });

    test('leaves other status codes alone', () {
      expect(
        AccountStateService.refusedState(
          _refusal(401, <String, dynamic>{'code': 'account_suspended'}),
        ),
        isNull,
      );
    });
  });

  group('pushes', () {
    test('a state the push names is read straight off it', () {
      expect(
        AccountStateService.statusFromBody(<String, dynamic>{
          'type': 'account_status',
          'status': 'suspended',
        }),
        AccountStatus.suspended,
      );
      expect(
        AccountStateService.statusFromBody(<String, dynamic>{
          'type': 'account_status',
          'account_status': 'inactive',
        }),
        AccountStatus.inactive,
      );
    });

    test('a reactivation is reported as active, not as a sign-out', () {
      expect(
        AccountStateService.statusFromBody(<String, dynamic>{
          'type': 'account_status',
          'account_status': 'active',
        }),
        AccountStatus.active,
      );
    });

    test('wording alone names no state', () {
      expect(
        AccountStateService.statusFromBody(<String, dynamic>{
          'type': 'account_status',
          'message': 'تم إلغاء إيقاف حسابك',
        }),
        isNull,
      );
    });

    test('an account announcement asks the API to confirm', () {
      expect(
        AccountStateService.isAccountStatusPush(<String, dynamic>{
          'type': 'account_status',
        }),
        isTrue,
      );
      expect(
        AccountStateService.isAccountStatusPush(<String, dynamic>{
          'type': 'new_content',
        }),
        isFalse,
      );
    });
  });

  group('the signed-in user', () {
    AuthUserModel userWith(String? status) =>
        AuthUserModel.fromJson(<String, dynamic>{
          'id': 9,
          'full_name': 'أحمد محمد',
          if (status != null) 'status': status,
        });

    test('carries the status the API sent', () {
      expect(userWith('suspended').status, AccountStatus.suspended);
      expect(userWith('suspended').isActive, isFalse);
      expect(userWith('active').isActive, isTrue);
    });

    test('only an active account may use the app', () {
      for (final String status in const <String>[
        'pending',
        'suspended',
        'inactive',
        'deleted',
        'something_new',
      ]) {
        expect(userWith(status).isActive, isFalse, reason: status);
      }
    });

    test('falls back to active when the field is missing', () {
      expect(userWith(null).isActive, isTrue);
    });

    test('round-trips through the cache', () {
      expect(
        AuthUserModel.fromJson(userWith('suspended').toJson()).isActive,
        isFalse,
      );
    });
  });

  group('the profile', () {
    test('carries the state when the payload has one', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{
          'id': 9,
          'name': 'أحمد محمد',
          'status': 'suspended',
        }).status,
        AccountStatus.suspended,
      );
    });

    test('says nothing about the state when the payload does not', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{
          'id': 9,
          'name': 'أحمد محمد',
        }).status,
        isNull,
      );
    });
  });
}
