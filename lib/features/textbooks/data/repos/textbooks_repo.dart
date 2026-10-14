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
  Future<File> downloadTextbook(TextbookModel book) => downloads.download(book);

  void cancelDownload(int bookId) => downloads.cancel(bookId);

  Future<String> previewUrl(TextbookModel book) =>
      dataSource.requestDownloadUrl(book.id);

  Future<File?> downloadedFile(TextbookModel book) =>
      dataSource.downloadedBookFile(book.id);

  Future<Set<int>> downloadedBookIds(Iterable<int> bookIds) =>
      dataSource.downloadedBookIds(bookIds);
}
