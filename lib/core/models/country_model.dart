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
  final String isoCode;
  final String dialCode;

  final String nameEn;
  final String nameAr;
  final int minLength;
  final int maxLength;
  final List<int> groups;
  String get flag => String.fromCharCodes(
    isoCode.codeUnits.map((int unit) => 0x1F1E6 + unit - 0x41),
  );

  String get displayDialCode => '+$dialCode';

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
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
    if (consumed < nationalDigits.length) {
      buffer.write(nationalDigits.substring(consumed));
    }

    return buffer.toString();
  }

  String toE164(String nationalDigits) => '+$dialCode$nationalDigits';
}
