/// A dialling country: ISO code, calling code, localized names and the digit
/// bounds of its national (local) number.
class Country {
  const Country(
    this.isoCode,
    this.dialCode,
    this.nameEn,
    this.nameAr, {
    required this.minLength,
    required this.maxLength,
    this.groups = const <int>[3, 3, 3, 3],
  });

  /// ISO 3166-1 alpha-2, uppercase.
  final String isoCode;

  /// Calling code without the leading `+`.
  final String dialCode;

  final String nameEn;
  final String nameAr;

  /// Digit count bounds of the national number, excluding [dialCode] and any
  /// national trunk prefix (the leading `0` many countries use locally).
  final int minLength;
  final int maxLength;

  /// Digit-group sizes used to space the number as it is typed.
  final List<int> groups;

  /// Flag built from [isoCode] as regional-indicator symbols, so no flag
  /// assets ship with the app.
  String get flag => String.fromCharCodes(
    isoCode.codeUnits.map((int unit) => 0x1F1E6 + unit - 0x41),
  );

  String get displayDialCode => '+$dialCode';

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  /// Matches a free-text search against either name, the ISO code or the
  /// calling code (with or without its `+`).
  bool matches(String query) {
    final String term = query.trim().toLowerCase();
    if (term.isEmpty) return true;

    final String digits = term.replaceAll('+', '');

    return nameEn.toLowerCase().contains(term) ||
        nameAr.contains(term) ||
        isoCode.toLowerCase().contains(term) ||
        (digits.isNotEmpty && dialCode.startsWith(digits));
  }

  bool isValidNationalNumber(String nationalDigits) =>
      nationalDigits.length >= minLength && nationalDigits.length <= maxLength;

  /// Spaces [nationalDigits] into [groups], e.g. `958953288` -> `958 953 288`.
  String formatNational(String nationalDigits) {
    final StringBuffer buffer = StringBuffer();
    int consumed = 0;

    for (final int size in groups) {
      if (consumed >= nationalDigits.length) break;

      if (consumed > 0) buffer.write(' ');

      final int end = (consumed + size) > nationalDigits.length
          ? nationalDigits.length
          : consumed + size;
      buffer.write(nationalDigits.substring(consumed, end));
      consumed = end;
    }

    // Anything past the declared groups stays attached to the last one.
    if (consumed < nationalDigits.length) {
      buffer.write(nationalDigits.substring(consumed));
    }

    return buffer.toString();
  }

  /// Full E.164 number, e.g. `+963958953288`.
  String toE164(String nationalDigits) => '+$dialCode$nationalDigits';
}
