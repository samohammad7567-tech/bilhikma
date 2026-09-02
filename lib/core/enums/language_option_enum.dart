import 'package:flutter/widgets.dart';

enum LanguageOption {
  arabic(code: 'ar', label: 'language_arabic'),
  english(code: 'en', label: 'language_english');

  const LanguageOption({required this.code, required this.label});

  final String code;

  final String label;

  Locale get locale => Locale(code);

  static LanguageOption of(String code) => LanguageOption.values.firstWhere(
    (LanguageOption option) => option.code == code,
    orElse: () => LanguageOption.arabic,
  );
}
