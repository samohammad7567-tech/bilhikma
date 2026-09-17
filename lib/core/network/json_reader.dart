import '../utils/app_language.dart';

class Json {
  Json._();

  static String asString(Object? value) => (value ?? '').toString();

  static String? asOptionalString(Object? value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Translatable backend fields arrive as `{"ar": "...", "en": "..."}`.
  /// Resolves them to the app language, falling back to Arabic and then to any
  /// filled translation. A plain string passes through unchanged, so the same
  /// reader works whether or not the endpoint is translated.
  static String asLocalizedString(Object? value) =>
      asOptionalLocalizedString(value) ?? '';

  static String? asOptionalLocalizedString(Object? value) {
    if (value is! Map) return asOptionalString(value);

    final Map<String, dynamic> translations = asMap(value);
    final List<String> order = <String>[
      AppLanguage.code,
      AppLanguage.fallbackCode,
      ...translations.keys,
    ];

    for (final String code in order) {
      final String? text = asOptionalString(translations[code]);
      if (text != null) return text;
    }

    return null;
  }

  static int asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(asString(value)) ?? 0;
  }

  static int? asOptionalInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(asString(value));
  }

  static double asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(asString(value)) ?? 0;
  }

  static bool asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final String text = asString(value).toLowerCase();
    return text == 'true' || text == '1';
  }

  /// Distinguishes "the backend said false" from "the backend said nothing",
  /// which [asBool] flattens into the same `false`.
  static bool? asOptionalBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final String text = asString(value).toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static List<String> asStringList(Object? value) {
    if (value is! List) return const <String>[];

    return value
        .map(asString)
        .where((String item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  static List<int> asIntList(Object? value) {
    if (value is! List) return const <int>[];

    return value.map(asOptionalInt).whereType<int>().toList(growable: false);
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];

    return value.whereType<Map>().map(asMap).toList(growable: false);
  }

  static DateTime? asDateTime(Object? value) {
    if (value is DateTime) return value.toLocal();
    final String text = asString(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  static DateTime? asDate(Object? value) {
    if (value is DateTime) return value;
    final String text = asString(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static Duration? asDuration(Object? seconds) {
    final int? value = asOptionalInt(seconds);
    return value == null ? null : Duration(seconds: value);
  }

  static Map<String, dynamic> asMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static Map<String, dynamic>? asOptionalMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static List<T> asList<T>(
    Object? value,
    T Function(Map<String, dynamic> json) parse,
  ) {
    if (value is! List) return <T>[];

    return value
        .whereType<Map>()
        .map((Map row) => parse(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
