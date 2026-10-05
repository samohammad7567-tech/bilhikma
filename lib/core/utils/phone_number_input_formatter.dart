import 'package:flutter/services.dart';

import '../models/country_model.dart';

/// Keeps a national phone number digits-only, capped at the country's length
/// and spaced into the country's digit groups while the user types.
class PhoneNumberInputFormatter extends TextInputFormatter {
  const PhoneNumberInputFormatter(this.country);

  final Country country;

  static final RegExp _nonDigit = RegExp(r'\D');
  static final RegExp _digit = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(_nonDigit, '');

    // Allow one extra digit so a locally-typed trunk prefix ("0...") still
    // fits; it is stripped before the number is sent.
    final int limit = country.maxLength + (digits.startsWith('0') ? 1 : 0);
    final String capped = digits.length > limit
        ? digits.substring(0, limit)
        : digits;

    final int cursor = newValue.selection.end.clamp(0, newValue.text.length);
    final int digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(_nonDigit, '')
        .length;

    final String formatted = country.formatNational(capped);

    // Put the caret back after the same number of digits it preceded.
    int offset = 0;
    int seen = 0;
    while (offset < formatted.length && seen < digitsBeforeCursor) {
      if (_digit.hasMatch(formatted[offset])) seen++;
      offset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
