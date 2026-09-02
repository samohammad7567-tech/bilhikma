import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/services/prd_services.dart';
import '../../../../core/utils/cache_util.dart';

class DownloadedPdfsDataSource {
  const DownloadedPdfsDataSource();

  static const String _key = 'downloaded_pdf_files';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String bookKey(int bookId) => 'book:$bookId';

  static String attachmentKey(int contentId, int attachmentId) =>
      'attachment:$contentId:$attachmentId';

  Future<File?> fileFor(String key) async {
    final String? name = _entries()[key];
    if (name == null) return null;

    final Directory library = await PdfService.libraryDirectory();
    final File file = File('${library.path}/$name');

    if (file.existsSync()) return file;

    await forget(key);
    return null;
  }

  Future<Set<String>> available(Iterable<String> keys) async {
    final Map<String, String> entries = _entries();
    if (entries.isEmpty) return <String>{};

    final Directory library = await PdfService.libraryDirectory();
    final Set<String> present = <String>{};
    final List<String> stale = <String>[];

    for (final String key in keys) {
      final String? name = entries[key];
      if (name == null) continue;

      if (File('${library.path}/$name').existsSync()) {
        present.add(key);
      } else {
        stale.add(key);
      }
    }

    if (stale.isNotEmpty) await _forgetAll(stale);

    return present;
  }

  Future<void> remember(String key, File file) async {
    final Map<String, String> entries = _entries();

    final String? previous = entries[key];
    final String name = file.uri.pathSegments.last;
    if (previous == name) return;

    entries[key] = name;
    await _write(entries);

    if (previous != null) await _deleteByName(previous);
  }

  Future<void> forget(String key) => _forgetAll(<String>[key]);

  Future<void> clearAll() async {
    try {
      final Directory library = await PdfService.libraryDirectory();

      if (library.existsSync()) await library.delete(recursive: true);
    } catch (_) {}

    CacheUtil.remove(key: _key);

    revision.value++;
  }

  Future<void> _forgetAll(List<String> keys) async {
    final Map<String, String> entries = _entries();

    final List<String> removed = <String>[];
    for (final String key in keys) {
      final String? name = entries.remove(key);
      if (name != null) removed.add(name);
    }

    if (removed.isEmpty) return;

    await _write(entries);
    for (final String name in removed) {
      await _deleteByName(name);
    }
  }

  Future<void> _deleteByName(String name) async {
    try {
      final Directory library = await PdfService.libraryDirectory();
      final File file = File('${library.path}/$name');

      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  Future<void> _write(Map<String, String> entries) async {
    await CacheUtil.setString(key: _key, value: jsonEncode(entries));

    revision.value++;
  }

  Map<String, String> _entries() {
    final Object? raw = CacheUtil.get(key: _key);
    if (raw is! String || raw.isEmpty) return <String, String>{};

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};

      return decoded.map(
        (Object? key, Object? value) =>
            MapEntry<String, String>('$key', '$value'),
      );
    } catch (_) {
      return <String, String>{};
    }
  }
}
