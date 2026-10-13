import 'package:dio/dio.dart';

import '../enums/account_status_enum.dart';
import '../enums/notification_kind_enum.dart';

/// Reads "this account is suspended" out of whatever the platform hands the
/// app: a refused request, a push payload or a user object.
///
/// Suspending a student takes effect on their very next request — the token
/// they already hold starts answering 403. A 403 on its own is never enough to
/// act on, because locked lessons and foreign classes answer 403 as well, so a
/// suspension is only read when the refusal actually names one.
class AccountSuspensionService {
  AccountSuspensionService._();

  /// Error key emitted for a suspended account, translated in both locales.
  static const String errorKey = 'suspended_account';

  static const Set<String> _markerFields = <String>{
    'code',
    'error',
    'error_code',
    'status',
    'account_status',
    'reason',
    'reason_type',
  };

  static const Set<String> _markerValues = <String>{
    'suspended',
    'account_suspended',
    'suspended_account',
    'user_suspended',
    'account_locked',
  };

  /// Suspension wording the API may send instead of a machine code, in both
  /// languages it serves. `يقاف` covers إيقاف / ايقاف / الإيقاف.
  static const List<String> _refusalWording = <String>[
    'suspend',
    'يقاف',
    'موقوف',
    'معلق',
    'تعليق',
  ];

  static const Set<String> _typeFields = <String>{
    'type',
    'notification_type',
    'kind',
  };

  /// True when [error] is a request the API refused because the account is
  /// suspended.
  static bool indicatesSuspension(Object error) {
    if (error is! DioException) return false;

    final Response<dynamic>? response = error.response;
    if (response == null || response.statusCode != 403) return false;

    final Object? body = response.data;

    return carriesMarker(body) || _refusalMentionsSuspension(body);
  }

  /// True when a push payload states the suspension outright, so the app can
  /// act without waiting for the next request to be refused. Only machine
  /// markers count here: an announcement about an account can just as easily
  /// be a reactivation, and its wording must not sign anybody out.
  static bool isSuspensionPush(Map<String, dynamic> data) => carriesMarker(data);

  /// True when a push is about the account itself, which is the cue to ask the
  /// API what the account's state is now.
  static bool isAccountStatusPush(Map<String, dynamic> data) {
    for (final String field in _typeFields) {
      final Object? value = data[field];
      if (value is! String) continue;

      if (NotificationKind.fromJson(value) == NotificationKind.accountStatus) {
        return true;
      }
    }

    return false;
  }

  /// True when the user object the API returned is already suspended.
  static bool isSuspendedStatus(Object? value) =>
      AccountStatus.maybeFromJson(value) == AccountStatus.suspended;

  /// Scans a body for an explicit suspension code or flag, nested data
  /// included.
  static bool carriesMarker(Object? data, {int depth = 0}) {
    if (data is! Map || depth > 3) return false;

    if (data['account_suspended'] == true) return true;

    for (final String field in _markerFields) {
      final Object? value = data[field];
      if (value is String &&
          _markerValues.contains(value.trim().toLowerCase())) {
        return true;
      }
    }

    for (final String nested in const <String>['data', 'errors', 'meta']) {
      if (carriesMarker(data[nested], depth: depth + 1)) return true;
    }

    return false;
  }

  static bool _refusalMentionsSuspension(Object? body) {
    if (body is! Map) return false;

    final Object? message = body['message'];
    if (message is! String) return false;

    final String text = message.toLowerCase();

    for (final String wording in _refusalWording) {
      if (text.contains(wording)) return true;
    }

    return false;
  }
}
