import 'dart:io';

import '../data_source/book_downloads_data_source.dart';
import '../data_source/textbooks_data_source.dart';
import '../../../../core/models/textbook_model.dart';

class TextbooksRepo {
  TextbooksRepo({
    TextbooksDataSource? dataSource,
    BookDownloadsDataSource? downloads,
  }) : this._(dataSource ?? TextbooksDataSource(), downloads);

  TextbooksRepo._(
    TextbooksDataSource source,
    BookDownloadsDataSource? downloads,
  ) : dataSource = source,
      downloads = downloads ?? BookDownloadsDataSource(textbooks: source);

  final TextbooksDataSource dataSource;
  final BookDownloadsDataSource downloads;

  Future<List<TextbookModel>> fetchTextbooks() => dataSource.fetchTextbooks();

  /// Joins the transfer already running for this book, when there is one.
  Future<File> downloadTextbook(TextbookModel book) => downloads.download(book);

  Future<File> fetchForPreview(
    TextbookModel book, {
    DownloadProgressCallback? onProgress,
  }) => dataSource.fetchForPreview(book, onProgress: onProgress);

  Future<Set<int>> downloadedBookIds(Iterable<int> bookIds) =>
      dataSource.downloadedBookIds(bookIds);
}
