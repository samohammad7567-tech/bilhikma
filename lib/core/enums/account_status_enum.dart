import '../network/json_reader.dart';

enum AccountStatus {
  active('active'),
  pending('pending'),
  suspended('suspended'),
  inactive('inactive');

  const AccountStatus(this.key);

  final String key;

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
