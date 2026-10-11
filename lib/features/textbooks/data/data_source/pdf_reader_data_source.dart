import 'dart:convert';

import '../../../../core/constants/cache_keys.dart';
import '../../../../core/enums/book_page_layout_enum.dart';
import '../../../../core/utils/cache_util.dart';
import '../models/reading_position.dart';

/// What the PDF reader remembers between sessions: where each document was
/// left, and how the user prefers pages laid out.
class PdfReaderDataSource {
  const PdfReaderDataSource();

  /// Positions are pruned to the most recently read documents, so a long
  /// lived install does not grow the preference file without bound.
  static const int _maxPositions = 120;

  /// Read synchronously: preferences are open before the first frame, so the
  /// viewer can be built already pointing at the saved page rather than
  /// jumping there after a load.
  ReadingPosition? positionFor(String key) {
    final Map<String, dynamic> entries = _entries();

    final Object? stored = entries[key];
    if (stored is! Map) return null;

    try {
      return ReadingPosition.fromJson(Map<String, dynamic>.from(stored));
    } catch (_) {
      return null;
    }
  }

  Future<void> savePosition(String key, ReadingPosition position) async {
    final Map<String, dynamic> entries = _entries()..[key] = position.toJson();

    await _write(_pruned(entries));
  }

  Future<void> forgetPosition(String key) async {
    final Map<String, dynamic> entries = _entries();
    if (entries.remove(key) == null) return;

    await _write(entries);
  }

  Future<void> clearPositions() async {
    CacheUtil.remove(key: CacheKeys.pdfReadingPositions);
  }

  BookPageLayout get layout =>
      BookPageLayout.fromJson(CacheUtil.get(key: CacheKeys.pdfPageLayout));

  Future<void> saveLayout(BookPageLayout layout) =>
      CacheUtil.setString(key: CacheKeys.pdfPageLayout, value: layout.key);

  /// Drops the least recently read entries once the store is over size.
  Map<String, dynamic> _pruned(Map<String, dynamic> entries) {
    if (entries.length <= _maxPositions) return entries;

    final List<String> byAge = entries.keys.toList()
      ..sort(
        (String a, String b) => _stampOf(entries[b]) - _stampOf(entries[a]),
      );

    return <String, dynamic>{
      for (final String key in byAge.take(_maxPositions)) key: entries[key]!,
    };
  }

  int _stampOf(Object? entry) {
    if (entry is! Map) return 0;

    final Object? stamp = entry['updated_at'];
    return stamp is int ? stamp : 0;
  }

  Future<void> _write(Map<String, dynamic> entries) => CacheUtil.setString(
    key: CacheKeys.pdfReadingPositions,
    value: jsonEncode(entries),
  );

  Map<String, dynamic> _entries() {
    final Object? raw = CacheUtil.get(key: CacheKeys.pdfReadingPositions);
    if (raw is! String || raw.isEmpty) return <String, dynamic>{};

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, dynamic>{};

      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
