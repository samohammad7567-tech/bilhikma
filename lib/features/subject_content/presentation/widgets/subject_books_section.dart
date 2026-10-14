import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/download_progress.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/models/textbook_model.dart';
import 'subject_book_card.dart';

class SubjectBooksSection extends StatelessWidget {
  const SubjectBooksSection({
    required this.books,
    required this.downloadingBookIds,
    required this.previewingBookId,
    required this.onDownload,
    required this.onPreview,
    required this.onOpen,
    required this.progressFor,
    super.key,
    this.onCancelDownload,
    this.downloadedBookIds = const <int>{},
    this.cancellingBookIds = const <int>{},
  });

  final List<TextbookModel> books;
  final Set<int> downloadingBookIds;
  final int? previewingBookId;
  final ValueChanged<TextbookModel> onDownload;
  final ValueChanged<TextbookModel> onPreview;
  final ValueChanged<TextbookModel> onOpen;
  final ValueChanged<TextbookModel>? onCancelDownload;
  final DownloadProgress? Function(int bookId) progressFor;
  final Set<int> downloadedBookIds;
  final Set<int> cancellingBookIds;

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
              progress: progressFor(book.id),
              isDownloading: downloadingBookIds.contains(book.id),
              isPreviewing: book.id == previewingBookId,
              isDownloaded: downloadedBookIds.contains(book.id),
              isCancelling: cancellingBookIds.contains(book.id),
              onDownload: () => onDownload(book),
              onCancelDownload: onCancelDownload == null
                  ? null
                  : () => onCancelDownload!(book),
              onPreview: () => onPreview(book),
              onOpen: () => onOpen(book),
            ),
          ),
      ],
    );
  }
}
