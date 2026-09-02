import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/models/textbook_model.dart';
import 'subject_book_card.dart';

class SubjectBooksSection extends StatelessWidget {
  const SubjectBooksSection({
    required this.books,
    required this.downloadingBookId,
    required this.previewingBookId,
    required this.onDownload,
    required this.onPreview,
    super.key,
    this.downloadedBookIds = const <int>{},
  });

  final List<TextbookModel> books;
  final int? downloadingBookId;
  final int? previewingBookId;
  final ValueChanged<TextbookModel> onDownload;
  final ValueChanged<TextbookModel> onPreview;
  final Set<int> downloadedBookIds;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const AppEmptyView(
        icon: Icons.menu_book_outlined,
        messageKey: 'no_books',
      );
    }

    return Column(
      children: <Widget>[
        for (final TextbookModel book in books)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: SubjectBookCard(
              book: book,
              isDownloading: book.id == downloadingBookId,
              isPreviewing: book.id == previewingBookId,
              isDownloaded: downloadedBookIds.contains(book.id),
              onDownload: () => onDownload(book),
              onPreview: () => onPreview(book),
            ),
          ),
      ],
    );
  }
}
