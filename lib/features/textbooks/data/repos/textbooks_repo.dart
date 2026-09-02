import 'dart:io';

import '../data_source/textbooks_data_source.dart';
import '../../../../core/models/textbook_model.dart';

class TextbooksRepo {
  TextbooksRepo({TextbooksDataSource? dataSource})
    : dataSource = dataSource ?? TextbooksDataSource();

  final TextbooksDataSource dataSource;

  Future<List<TextbookModel>> fetchTextbooks() => dataSource.fetchTextbooks();

  Future<File> downloadTextbook(TextbookModel book) =>
      dataSource.downloadTextbook(book);

  Future<File> fetchForPreview(TextbookModel book) =>
      dataSource.fetchForPreview(book);

  Future<Set<int>> downloadedBookIds(Iterable<int> bookIds) =>
      dataSource.downloadedBookIds(bookIds);
}
