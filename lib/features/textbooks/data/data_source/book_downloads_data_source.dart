import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../../core/utils/download_progress_throttle.dart';
import '../../../../core/utils/error_mapper.dart';
import 'textbooks_data_source.dart';

/// Owns book downloads for the whole app so a transfer outlives the screen
/// that started it: popping back shows the bar where it actually is, and a
/// second tap joins the running download instead of starting another one.
class BookDownloadsDataSource {
  BookDownloadsDataSource({TextbooksDataSource? textbooks})
    : textbooks = textbooks ?? TextbooksDataSource();

  final TextbooksDataSource textbooks;

  /// Static so every instance shares one view of what is in flight, however
  /// that instance was built.
  static final ValueNotifier<Map<int, DownloadProgress>> active =
      ValueNotifier<Map<int, DownloadProgress>>(
        const <int, DownloadProgress>{},
      );

  static final Map<int, Future<File>> _inFlight = <int, Future<File>>{};

  static final Map<int, DownloadProgressThrottle> _throttles =
      <int, DownloadProgressThrottle>{};

  /// Error keys from downloads that ended while no screen was listening.
  static final Map<int, String> _missedFailures = <int, String>{};

  static bool isDownloading(int bookId) => _inFlight.containsKey(bookId);

  static Map<int, DownloadProgress> get snapshot => active.value;

  /// Reads and clears the failure, so it is reported once and not again.
  static String? takeMissedFailure(int bookId) =>
      _missedFailures.remove(bookId);

  /// Returns the download already running for this book when there is one, so
  /// every caller awaits the same transfer.
  Future<File> download(TextbookModel book) {
    final Future<File>? running = _inFlight[book.id];
    if (running != null) return running;

    _throttles[book.id] = DownloadProgressThrottle();
    _missedFailures.remove(book.id);
    _publish(book.id, DownloadProgress.none);

    final Future<File> task = _run(book);
    _inFlight[book.id] = task;

    return task;
  }

  Future<File> _run(TextbookModel book) async {
    try {
      return await textbooks.downloadTextbook(
        book,
        onProgress: (DownloadProgress progress) =>
            _onProgress(book.id, progress),
      );
    } catch (error) {
      _missedFailures[book.id] = ErrorMapper.map(error);
      rethrow;
    } finally {
      _finish(book.id);
    }
  }

  void _onProgress(int bookId, DownloadProgress progress) {
    final DownloadProgressThrottle? throttle = _throttles[bookId];
    if (throttle != null && !throttle.shouldEmit(progress)) return;

    _publish(bookId, progress);
  }

  void _publish(int bookId, DownloadProgress progress) {
    active.value = <int, DownloadProgress>{...active.value, bookId: progress};
  }

  void _finish(int bookId) {
    _inFlight.remove(bookId);
    _throttles.remove(bookId);

    final Map<int, DownloadProgress> next = <int, DownloadProgress>{
      ...active.value,
    }..remove(bookId);

    active.value = next;
  }
}
