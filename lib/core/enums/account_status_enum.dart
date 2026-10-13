import '../network/json_reader.dart';

enum AccountStatus {
  active('active'),
  pending('pending'),
  suspended('suspended'),
  inactive('inactive');

  const AccountStatus(this.key);

  final String key;

  /// Tolerant reader for payloads that may omit the field or send a value the
  /// app does not know yet: the caller decides what to fall back to instead of
  /// losing the whole response to an error.
  static AccountStatus? maybeFromJson(Object? value) {
    final String key = Json.asString(value).trim().toLowerCase();

    for (final AccountStatus status in AccountStatus.values) {
      if (status.key == key) return status;
    }

    return null;
  }

  static AccountStatus fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    switch (key) {
      case 'active':
        return AccountStatus.active;
      case 'pending':
        return AccountStatus.pending;
      case 'suspended':
        return AccountStatus.suspended;
      case 'inactive':
        return AccountStatus.inactive;
      default:
        throw ArgumentError.value(value, 'value', 'Unknown account status');
    }
  }
}
