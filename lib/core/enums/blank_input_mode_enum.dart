enum BlankInputMode {
  wordBank('word_bank'),
  dropdown('dropdown');

  const BlankInputMode(this.key);

  final String key;

  static BlankInputMode fromJson(Object? value) {
    final String key = (value ?? '').toString().toLowerCase().trim();

    return BlankInputMode.values.firstWhere(
      (BlankInputMode mode) => mode.key == key,
      orElse: () => throw const FormatException('unsupported_blank_input_mode'),
    );
  }
}
