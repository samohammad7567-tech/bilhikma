import '../network/json_reader.dart';

enum LiveSessionStatus {
  scheduled('scheduled'),
  live('live'),
  ended('ended'),
  cancelled('cancelled');

  const LiveSessionStatus(this.key);

  final String key;

  static LiveSessionStatus fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();
    return LiveSessionStatus.values.firstWhere(
      (LiveSessionStatus status) => status.key == key,
      orElse: () => LiveSessionStatus.scheduled,
    );
  }
}
