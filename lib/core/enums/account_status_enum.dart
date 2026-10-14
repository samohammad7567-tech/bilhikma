import '../network/json_reader.dart';

/// The state the platform keeps a student account in.
///
/// Only [active] lets a student use the app. Every other state ends the
/// session and sends them back to the login screen — [unknown] included, which
/// is a state the platform started sending after this build shipped and which
/// must not be mistaken for an active account.
enum AccountStatus {
  active('active'),
  pending('pending', noticeKey: 'pending_account'),
  suspended('suspended', noticeKey: 'suspended_account'),
  inactive('inactive', noticeKey: 'inactive_account'),
  deleted('deleted', noticeKey: 'deleted_account'),
  unknown('unknown', noticeKey: 'account_not_active');

  const AccountStatus(this.key, {this.noticeKey});

  final String key;

  /// Localization key telling the student why they were signed out. Null for
  /// [active], which never signs anybody out.
  final String? noticeKey;

  bool get isActive => this == AccountStatus.active;

  /// Reads a value the app already knows is the account's own state.
  ///
  /// Null only when there is nothing to read, so an absent or empty field
  /// leaves the decision to the caller instead of locking a student out over a
  /// payload that simply does not carry the field. A value that is present but
  /// not one this build knows is [unknown]: it is not `active`, and treating
  /// it as such would keep a student in the app the platform has shut out.
  static AccountStatus? maybeFromJson(Object? value) {
    final String key = Json.asString(value).trim().toLowerCase();
    if (key.isEmpty) return null;

    for (final AccountStatus status in AccountStatus.values) {
      if (status.key == key) return status;
    }

    return AccountStatus.unknown;
  }
}
