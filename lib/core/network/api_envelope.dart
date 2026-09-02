import 'json_reader.dart';

class ApiEnvelope {
  const ApiEnvelope({
    required this.statusCode,
    this.data,
    this.message,
    this.errors = const <String, List<String>>{},
  });

  final int statusCode;
  final Object? data;
  final String? message;

  final Map<String, List<String>> errors;

  bool get isSuccess => statusCode == 1;

  Map<String, dynamic> get dataMap => Json.asMap(data);

  String? get firstError {
    for (final List<String> messages in errors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return null;
  }

  List<String> errorsFor(String field) => errors[field] ?? const <String>[];

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) => ApiEnvelope(
    statusCode: Json.asInt(json['status_code']),
    data: json['data'],
    message: Json.asOptionalString(json['message']),
    errors: _parseErrors(json['errors']),
  );

  static Map<String, List<String>> _parseErrors(Object? value) {
    if (value is! Map) return const <String, List<String>>{};

    return <String, List<String>>{
      for (final MapEntry<dynamic, dynamic> entry in value.entries)
        entry.key.toString(): entry.value is List
            ? (entry.value as List<dynamic>)
                  .map(Json.asString)
                  .toList(growable: false)
            : <String>[Json.asString(entry.value)],
    };
  }
}
