class PathwayViewData {
  PathwayViewData._();

  static List<String> infoValues(List<String> values) => values
      .where((String value) => value.trim().isNotEmpty)
      .toList(growable: false);
}
