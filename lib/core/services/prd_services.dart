import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  PdfService({Dio? dio}) : dio = dio ?? Dio();

  final Dio dio;

  static const String _folder = 'textbooks';

  static Future<Directory> libraryDirectory() async {
    final Directory documents = await getApplicationDocumentsDirectory();

    return Directory('${documents.path}/$_folder');
  }

  static Future<Directory> cacheDirectory() async {
    final Directory cache = await getTemporaryDirectory();

    return Directory('${cache.path}/$_folder');
  }

  Future<File> downloadPdf({
    required String pdfUrl,
    String? fileName,
    ProgressCallback? onProgress,
  }) async => _download(
    pdfUrl: pdfUrl,
    directory: await libraryDirectory(),
    fileName: fileName,
    onProgress: onProgress,
  );

  Future<File> downloadToCache({
    required String pdfUrl,
    String? fileName,
    ProgressCallback? onProgress,
  }) async => _download(
    pdfUrl: pdfUrl,
    directory: await cacheDirectory(),
    fileName: fileName,
    onProgress: onProgress,
  );

  Future<void> clearCache() async {
    final Directory cache = await cacheDirectory();
    if (!cache.existsSync()) return;

    try {
      await cache.delete(recursive: true);
    } catch (_) {}
  }

  Future<File> _download({
    required String pdfUrl,
    required Directory directory,
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final String path = '${directory.path}/${_uniqueName(fileName)}';

    final File file = File(path);
    if (file.existsSync()) await file.delete();

    try {
      await dio.download(pdfUrl, path, onReceiveProgress: onProgress);
    } catch (_) {
      if (file.existsSync()) await file.delete();
      rethrow;
    }

    return file;
  }

  String _uniqueName(String? fileName) {
    final String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String base = _sanitize(fileName ?? '');

    return base.isEmpty ? 'document_$stamp.pdf' : '${base}_$stamp.pdf';
  }

  String _sanitize(String name) {
    final String withoutExtension = name.toLowerCase().endsWith('.pdf')
        ? name.substring(0, name.length - 4)
        : name;

    return withoutExtension
        .replaceAll(RegExp(r'[\/:*?"<>|\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
