class ByteFormat {
  ByteFormat._();

  static const List<String> _units = <String>['B', 'KB', 'MB', 'GB'];
  static String readable(int bytes) {
    if (bytes <= 0) return '';

    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < _units.length - 1) {
      size /= 1024;
      unit++;
    }

    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${_units[unit]}';
  }

  static String readableValue(int bytes, {required int referenceBytes}) {
    if (bytes < 0) return '';

    final int unit = _unitOf(referenceBytes);
    final double size = bytes / _factor(unit);

    return size.toStringAsFixed(unit == 0 ? 0 : 1);
  }

  static String unitOf(int bytes) => _units[_unitOf(bytes)];

  static int _unitOf(int bytes) {
    if (bytes <= 0) return 0;

    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < _units.length - 1) {
      size /= 1024;
      unit++;
    }

    return unit;
  }

  static double _factor(int unit) {
    double factor = 1;
    for (int index = 0; index < unit; index++) {
      factor *= 1024;
    }

    return factor;
  }
}
