import '../../../../core/enums/book_page_layout_enum.dart';
import '../data_source/pdf_reader_data_source.dart';
import '../models/reading_position.dart';

class PdfReaderRepo {
  const PdfReaderRepo({this.dataSource = const PdfReaderDataSource()});

  final PdfReaderDataSource dataSource;

  ReadingPosition? positionFor(String key) => dataSource.positionFor(key);

  Future<void> savePosition(String key, ReadingPosition position) =>
      dataSource.savePosition(key, position);

  Future<void> forgetPosition(String key) => dataSource.forgetPosition(key);

  BookPageLayout get layout => dataSource.layout;

  Future<void> saveLayout(BookPageLayout layout) =>
      dataSource.saveLayout(layout);
}
