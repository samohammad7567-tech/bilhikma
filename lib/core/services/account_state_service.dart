import 'package:dio/dio.dart';

import '../enums/account_status_enum.dart';
import '../enums/notification_kind_enum.dart';

/// Reads the state of the signed-in account out of whatever the platform hands
/// the app: a refused request, a push payload or a user object.
///
/// Only an active account may use the app. Changing that is a dashboard
/// action, and it takes effect on the student's very next request — the token
/// they already hold starts answering 403. A 403 on its own is never enough to
/// act on, because locked lessons and foreign classes answer 403 as well, so
/// the session is only dropped when the refusal actually names the account.
class AccountStateService {
  AccountStateService._();

  /// Shown when the account is no longer active but nothing named which state
  /// it moved to.
  static const String fallbackKey = 'account_not_active';

  /// The message a student is signed out with for [status].
  static String noticeKeyFor(AccountStatus status) =>
      status.noticeKey ?? fallbackKey;

  /// Fields that can only be describing the account, so whatever they carry is
  /// read as the account's state.
  static const Set<String> _accountFields = <String>{
    'account_status',
    'user_status',
  };

  /// Fields an account state may arrive in that other records use too. A
  /// lesson, an enrollment and a live session all carry a plain `status`, so
  /// only wording that names an account is read from these.
  static const Set<String> _sharedFields = <String>{
    'code',
    'error',
    'error_code',
    'status',
    'reason',
    'reason_type',
  };

  /// Wording the API may send instead of the state itself.
  ///
  /// Bare `pending`, `inactive` and `deleted` are deliberately absent: an
  /// enrollment awaiting approval and a removed lesson carry exactly those in
  /// a plain `status`, and reading one of them as the account's state would
  /// sign a student out over somebody else's record.
  static const Map<String, AccountStatus> _accountWords =
      <String, AccountStatus>{
        'suspended': AccountStatus.suspended,
        'account_suspended': AccountStatus.suspended,
        'suspended_account': AccountStatus.suspended,
        'user_suspended': AccountStatus.suspended,
        'account_locked': AccountStatus.suspended,
        'account_inactive': AccountStatus.inactive,
        'user_inactive': AccountStatus.inactive,
        'account_pending': AccountStatus.pending,
        'pending_activation': AccountStatus.pending,
        'account_deleted': AccountStatus.deleted,
        'user_deleted': AccountStatus.deleted,
        'account_not_active': AccountStatus.unknown,
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

  /// The state a refused request names, or null when the refusal is about
  /// anything else. An active account is reported as null too: there is
  /// nothing to act on, whatever the request was refused for.
  static AccountStatus? refusedState(Object error) {
    if (error is! DioException) return null;

    final Response<dynamic>? response = error.response;
    if (response == null || response.statusCode != 403) return null;

    final Object? body = response.data;

    final AccountStatus? state =
        statusFromBody(body) ?? _wordedSuspension(body);

    return state == null || state.isActive ? null : state;
  }

  /// Reads the account state out of a response body or a push payload, so the
  /// app can act on it without waiting for the next request to be refused.
  ///
  /// May report [AccountStatus.active]: a push about an account is just as
  /// likely to be a reactivation, and the caller decides what that means.
  static AccountStatus? statusFromBody(Object? data, {int depth = 0}) {
    if (data is! Map || depth > 3) return null;

    if (data['account_suspended'] == true) return AccountStatus.suspended;

    for (final String field in _accountFields) {
      final AccountStatus? state = AccountStatus.maybeFromJson(data[field]);
      if (state != null) return state;
    }

    final Object? user = data['user'];
    if (user is Map) {
      final AccountStatus? state = AccountStatus.maybeFromJson(user['status']);
      if (state != null) return state;
    }

    for (final String field in _sharedFields) {
      final Object? value = data[field];
      if (value is! String) continue;

      final AccountStatus? state = _accountWords[value.trim().toLowerCase()];
      if (state != null) return state;
    }

    for (final String nested in const <String>['data', 'errors', 'meta']) {
      final AccountStatus? state = statusFromBody(
        data[nested],
        depth: depth + 1,
      );
      if (state != null) return state;
    }

    return null;
  }

  /// True when a push is about the account itself without naming the state it
  /// moved to, which is the cue to ask the API what that state is now.
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

  static AccountStatus? _wordedSuspension(Object? body) {
    if (body is! Map) return null;

    final Object? message = body['message'];
    if (message is! String) return null;

    final String text = message.toLowerCase();

    for (final String wording in _refusalWording) {
      if (text.contains(wording)) return AccountStatus.suspended;
    }

    return null;
  }
}
